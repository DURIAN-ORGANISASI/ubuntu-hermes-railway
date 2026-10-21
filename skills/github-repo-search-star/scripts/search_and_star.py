#!/usr/bin/env python3
"""Search GitHub repositories by topic and optionally star new matches.

Uses only Python's standard library. The token is read from GITHUB_TOKEN,
or from HERMES_HOME/.env as a fallback. Never prints the token or HTTP headers.
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode, quote
from urllib.request import Request, urlopen

API = "https://api.github.com"
API_VERSION = "2022-11-28"
USER_AGENT = "ubuntu-hermes-railway-github-repo-search-star"


def emit(payload: dict, exit_code: int = 0) -> None:
    print(json.dumps(payload, ensure_ascii=False, indent=2))
    raise SystemExit(exit_code)


def load_token() -> str:
    token = os.environ.get("GITHUB_TOKEN", "").strip()
    if token:
        return token

    home = Path(os.environ.get("HERMES_HOME", "/opt/data"))
    env_file = home / ".env"
    try:
        for line in env_file.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("export "):
                line = line[7:].lstrip()
            if "=" not in line:
                continue
            key, value = line.split("=", 1)
            if key.strip() != "GITHUB_TOKEN":
                continue
            value = value.strip()
            if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
                value = value[1:-1]
            return value.strip()
    except OSError:
        pass
    return ""


def request_api(token: str, method: str, path: str, params: dict | None = None):
    url = API + path
    if params:
        url += "?" + urlencode(params)
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": API_VERSION,
        "User-Agent": USER_AGENT,
    }
    data = b"" if method == "PUT" else None
    request = Request(url, headers=headers, method=method, data=data)
    try:
        with urlopen(request, timeout=25) as response:
            body = response.read()
            try:
                payload = json.loads(body.decode("utf-8")) if body else None
            except (UnicodeDecodeError, json.JSONDecodeError):
                payload = None
            return response.status, payload
    except HTTPError as error:
        # Do not echo raw API bodies into chat; keep possible account details out.
        return error.code, None
    except (URLError, TimeoutError, OSError):
        return 0, None


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Search GitHub for relevant repositories and star them."
    )
    parser.add_argument("--query", required=True, help="Concise topic keywords, preferably in English")
    parser.add_argument("--count", type=int, default=5, help="Number of NEW repositories to star (1-20, default: 5)")
    parser.add_argument("--dry-run", action="store_true", help="Search and report candidates without starring")
    args = parser.parse_args()

    query = args.query.strip()
    if len(query) < 2 or len(query) > 200:
        emit({"status": "error", "error": "Query must contain between 2 and 200 characters."}, 2)
    if not 1 <= args.count <= 20:
        emit({"status": "error", "error": "Count must be between 1 and 20 per request."}, 2)

    token = load_token()
    if not token:
        emit({
            "status": "error",
            "error": "GITHUB_TOKEN is missing. Add it to Railway Variables, or to HERMES_HOME/.env with file permissions 600."
        }, 2)

    status, user = request_api(token, "GET", "/user")
    if status != 200 or not isinstance(user, dict) or not user.get("login"):
        message = "GitHub authentication failed. Check that GITHUB_TOKEN is valid and has not expired."
        if status in (403, 429):
            message = "GitHub rejected authentication or rate-limited the request. Check token permissions and quota."
        emit({"status": "error", "http_status": status, "error": message}, 1)

    # Search public repositories; exclude archived repos and forks by default.
    search_query = f"{query} in:name,description,readme fork:false archived:false"
    status, result = request_api(
        token,
        "GET",
        "/search/repositories",
        {"q": search_query, "sort": "stars", "order": "desc", "per_page": 100},
    )
    if status != 200 or not isinstance(result, dict):
        message = "GitHub repository search failed. Check token permissions and rate limits."
        emit({"status": "error", "http_status": status, "error": message, "query": query}, 1)

    items = result.get("items") or []
    if not items:
        emit({
            "status": "no_results",
            "github_account": user["login"],
            "query": query,
            "requested_new_stars": args.count,
            "starred": [],
            "already_starred": [],
            "message": "No matching repositories found. Retry with shorter, more specific English keywords."
        })

    starred = []
    would_star = []
    already_starred = []
    considered = 0

    for item in items:
        if not isinstance(item, dict):
            continue
        full_name = item.get("full_name")
        if not full_name or item.get("fork") or item.get("archived"):
            continue
        considered += 1
        encoded_name = quote(full_name, safe="/")
        check_status, _ = request_api(token, "GET", f"/user/starred/{encoded_name}")

        summary = {
            "full_name": full_name,
            "url": item.get("html_url", f"https://github.com/{full_name}"),
            "description": item.get("description") or "",
            "stars": item.get("stargazers_count", 0),
            "language": item.get("language"),
        }

        if check_status == 204:
            already_starred.append(summary)
            continue
        if check_status != 404:
            emit({
                "status": "error",
                "http_status": check_status,
                "github_account": user["login"],
                "query": query,
                "error": "Could not check Starred status. Verify Starring read/write permission and GitHub API quota.",
                "starred": starred,
                "already_starred": already_starred,
            }, 1)

        if args.dry_run:
            summary["action"] = "would_star"
            would_star.append(summary)
        else:
            star_status, _ = request_api(token, "PUT", f"/user/starred/{encoded_name}")
            if star_status == 204:
                summary["action"] = "starred"
                starred.append(summary)
            else:
                emit({
                    "status": "error",
                    "http_status": star_status,
                    "github_account": user["login"],
                    "query": query,
                    "error": "GitHub could not add the star. Check Starring: read/write and repository metadata access.",
                    "starred": starred,
                    "already_starred": already_starred,
                }, 1)

        if len(would_star if args.dry_run else starred) >= args.count:
            break

    selected = would_star if args.dry_run else starred
    complete = len(selected) >= args.count
    if args.dry_run:
        out = {
            "status": "dry_run" if complete else "partial",
            "github_account": user["login"],
            "query": query,
            "requested_new_stars": args.count,
            "would_star": would_star,
            "already_starred": already_starred,
            "candidates_considered": considered,
            "message": "Preview only; no stars were added."
        }
    else:
        out = {
            "status": "success" if complete else "partial",
            "github_account": user["login"],
            "query": query,
            "requested_new_stars": args.count,
            "starred": starred,
            "already_starred": already_starred,
            "candidates_considered": considered,
            "message": (
                f"Added {len(starred)} new stars to @{user['login']}."
                if complete
                else f"Added {len(starred)} new stars; fewer than {args.count} unstarred matches were found."
            )
        }
    emit(out)


if __name__ == "__main__":
    main()
