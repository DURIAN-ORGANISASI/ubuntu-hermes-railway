---
name: github-repo-search-star
description: Search GitHub repositories for a topic and automatically star the most relevant repositories in the user's authenticated GitHub account when explicitly asked. Supports natural-language requests in Indonesian or English.
version: 1.0.0
author: DURIAN-ORGANISASI
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [github, repository-search, starring, automation]
    category: devops
    requires_toolsets: [terminal]
---

# GitHub Repository Search and Auto-Star

Use this skill when the user asks to find repositories about a topic and star the relevant results. The user does not need to supply repository URLs.

## Defaults and limits

- If the user does not specify a number, select **5 new repositories**.
- Respect an explicit requested count from 1 to 20. Never exceed 20 new stars in a single request.
- Only add stars when the user explicitly asks to star, favorite, or save the discovered repositories to their GitHub Starred list. If they ask only to search, return recommendations without starring.
- Use the connected token's account. Never ask the user to paste the token into chat, and never display it.
- Search public repositories. Exclude archived repositories and forks by default.
- Prefer relevant repositories with strong star counts, but relevance to the topic comes first.
- If a repository is already starred, skip it and keep searching so the request can still add the requested number of new stars.
- Do not fork, clone, modify, or execute code from repositories as part of this workflow.

## Procedure

1. Convert the user's topic into short, meaningful GitHub search terms, preferably in English. Remove instruction words like "carikan", "repo", "tolong", "kasih bintang", and "terbaik"; preserve product names, languages, platforms, and technical concepts.
2. If the topic is vague, choose the most reasonable interpretation and make the search query concrete. Do not ask for a URL; a URL is not required.
3. Execute the script using the terminal tool available to Hermes:

   ```bash
   python3 "${HERMES_HOME:-/opt/data}/skills/github/github-repo-search-star/scripts/search_and_star.py" --query "CONCISE SEARCH TERMS" --count 5
   ```

   Replace the query and count with values derived from the user's message. Omit `--count` if the user did not specify a number; the script defaults to 5.

4. Do not claim that a star was added until the script reports `status: success` or reports the individual repository under `starred`.
5. If the script reports `no_results`, retry once with shorter, broader keywords. If it still finds nothing, report that honestly.
6. Explain the result in Indonesian when the user speaks Indonesian. Summarize newly starred repositories with name, URL, star count at search time, and short description. Also report any already-starred repos that were skipped.
7. If fewer new matches exist than requested, report the actual count; never claim the full number succeeded.

## Error handling

- Missing token: instruct the operator to add `GITHUB_TOKEN` in Railway Variables.
- HTTP 401: the token may be invalid, revoked, or expired.
- HTTP 403/429: check GitHub permissions and rate limits.
- Star-check or star-write errors: confirm the fine-grained token has `Starring: read and write` and `Metadata: read-only`.
- Never print, echo, or include the access token in logs or chat.
