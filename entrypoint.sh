#!/usr/bin/env bash
set -Eeuo pipefail

: "${TERMINAL_USER:?Set TERMINAL_USER in Railway Variables}"
: "${TERMINAL_PASSWORD:?Set TERMINAL_PASSWORD in Railway Variables}"

if [[ "${TERMINAL_USER}" == *:* ]]; then
  echo "ERROR: TERMINAL_USER must not contain a colon (:)." >&2
  exit 1
fi
if [[ ${#TERMINAL_PASSWORD} -lt 16 ]]; then
  echo "ERROR: TERMINAL_PASSWORD must be at least 16 characters." >&2
  exit 1
fi

PORT="${PORT:-8080}"
HERMES_HOME="${HERMES_HOME:-/opt/data}"
HERMES_RUNTIME_DIR="${HERMES_RUNTIME_DIR:-/usr/local/share/hermes-tools}"
UV_CACHE_DIR="${UV_CACHE_DIR:-/tmp/uv-cache}"
export TZ="${TZ:-Asia/Jakarta}"
export HOME=/home/hermes
export USER=hermes
export LOGNAME=hermes
export HERMES_HOME HERMES_RUNTIME_DIR UV_CACHE_DIR

if [[ "${HERMES_HOME}" != "/opt/data" ]]; then
  echo "ERROR: HERMES_HOME must be /opt/data (mount the Railway Volume there)." >&2
  exit 1
fi
if [[ "${HERMES_RUNTIME_DIR}" != "/usr/local/share/hermes-tools" ]]; then
  echo "ERROR: HERMES_RUNTIME_DIR must be /usr/local/share/hermes-tools." >&2
  exit 1
fi
if [[ "${UV_CACHE_DIR}" != "/tmp/uv-cache" ]]; then
  echo "ERROR: UV_CACHE_DIR must be /tmp/uv-cache." >&2
  exit 1
fi
if [[ ! "${PORT}" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
  echo "ERROR: PORT must be a TCP port number from 1 to 65535." >&2
  exit 1
fi
if [[ -L "${HERMES_HOME}" || -L "${HERMES_RUNTIME_DIR}" ]]; then
  echo "ERROR: Hermes data/runtime root must not be a symlink." >&2
  exit 1
fi

mkdir -p "${HERMES_HOME}" "${HERMES_RUNTIME_DIR}" "${UV_CACHE_DIR}" /data /home/hermes

relocate_rebuildable_dir() {
  local persistent="$1"
  local runtime="$2"
  local current_target
  mkdir -p "$(dirname "${persistent}")" "$(dirname "${runtime}")"

  if [[ -L "${persistent}" ]]; then
    current_target="$(readlink "${persistent}")"
    if [[ "${current_target}" == "${runtime}" ]]; then
      mkdir -p "${runtime}"
      return 0
    fi
    echo "ERROR: ${persistent} is a symlink to an unexpected location: ${current_target}" >&2
    return 1
  fi

  if [[ -d "${persistent}" ]]; then
    mkdir -p "${runtime}"
    cp -a "${persistent}/." "${runtime}/" || {
      echo "ERROR: Could not migrate ${persistent} to ${runtime}; original data was kept." >&2
      return 1
    }
    rm -rf "${persistent}"
  elif [[ -e "${persistent}" ]]; then
    echo "ERROR: ${persistent} exists but is not a directory." >&2
    return 1
  else
    mkdir -p "${runtime}"
  fi

  ln -s "${runtime}" "${persistent}"
}

relocate_rebuildable_dir "${HERMES_HOME}/cache/partials" "${HERMES_RUNTIME_DIR}/cache/partials"
relocate_rebuildable_dir "${HERMES_HOME}/tools" "${HERMES_RUNTIME_DIR}/tools"

UV_PM_CACHE_DIR="${HERMES_HOME}/cache/uv"
UV_RUNTIME_CACHE_DIR="${HERMES_RUNTIME_DIR}/cache/uv"
mkdir -p "${HERMES_HOME}/cache" "${HERMES_RUNTIME_DIR}/cache"
if [[ -L "${UV_PM_CACHE_DIR}" ]]; then
  current_target="$(readlink "${UV_PM_CACHE_DIR}")"
  if [[ "${current_target}" != "${UV_RUNTIME_CACHE_DIR}" ]]; then
    echo "ERROR: ${UV_PM_CACHE_DIR} points to an unexpected location: ${current_target}" >&2
    exit 1
  fi
elif [[ -d "${UV_PM_CACHE_DIR}" ]]; then
  mkdir -p "${UV_RUNTIME_CACHE_DIR}"
  cp -a "${UV_PM_CACHE_DIR}/." "${UV_RUNTIME_CACHE_DIR}/" || {
    echo "ERROR: Could not migrate Hermes uv cache; original data was kept." >&2
    exit 1
  }
  rm -rf "${UV_PM_CACHE_DIR}"
elif [[ -e "${UV_PM_CACHE_DIR}" ]]; then
  echo "ERROR: ${UV_PM_CACHE_DIR} exists but is not a directory." >&2
  exit 1
else
  mkdir -p "${UV_RUNTIME_CACHE_DIR}"
fi
if [[ ! -L "${UV_PM_CACHE_DIR}" ]]; then
  ln -s "${UV_RUNTIME_CACHE_DIR}" "${UV_PM_CACHE_DIR}"
fi

PM_STATE_DIR="${HERMES_HOME}/installs"
PM_RUNTIME_STATE_DIR="${HERMES_RUNTIME_DIR}/installs"
if [[ -L "${PM_STATE_DIR}" ]]; then
  current_target="$(readlink "${PM_STATE_DIR}")"
  if [[ "${current_target}" != "${PM_RUNTIME_STATE_DIR}" ]]; then
    echo "ERROR: ${PM_STATE_DIR} points to an unexpected location: ${current_target}" >&2
    exit 1
  fi
  mkdir -p "${PM_RUNTIME_STATE_DIR}"
elif [[ -d "${PM_STATE_DIR}" ]]; then
  if [[ -e "${PM_RUNTIME_STATE_DIR}" ]]; then
    cp -a "${PM_STATE_DIR}/." "${PM_RUNTIME_STATE_DIR}/" || {
      echo "ERROR: Could not migrate Hermes PM state out of ${PM_STATE_DIR}; original data was kept." >&2
      exit 1
    }
    rm -rf "${PM_STATE_DIR}"
  else
    mv "${PM_STATE_DIR}" "${PM_RUNTIME_STATE_DIR}" || {
      echo "ERROR: Could not move Hermes PM state out of ${PM_STATE_DIR}." >&2
      exit 1
    }
  fi
  ln -s "${PM_RUNTIME_STATE_DIR}" "${PM_STATE_DIR}"
elif [[ -e "${PM_STATE_DIR}" ]]; then
  echo "ERROR: ${PM_STATE_DIR} exists but is not a directory or symlink." >&2
  exit 1
else
  mkdir -p "${PM_RUNTIME_STATE_DIR}"
  ln -s "${PM_RUNTIME_STATE_DIR}" "${PM_STATE_DIR}"
fi

BUNDLED_GITHUB_SKILL="/usr/local/share/ubuntu-hermes-railway/skills/github-repo-search-star"
INSTALLED_GITHUB_SKILL="${HERMES_HOME}/skills/github/github-repo-search-star"
if [[ -f "${BUNDLED_GITHUB_SKILL}/SKILL.md" && -f "${BUNDLED_GITHUB_SKILL}/scripts/search_and_star.py" ]]; then
  mkdir -p "${INSTALLED_GITHUB_SKILL}/scripts"
  install -m 0644 "${BUNDLED_GITHUB_SKILL}/SKILL.md" "${INSTALLED_GITHUB_SKILL}/SKILL.md"
  install -m 0755 "${BUNDLED_GITHUB_SKILL}/scripts/search_and_star.py" "${INSTALLED_GITHUB_SKILL}/scripts/search_and_star.py"
  echo "GitHub repository search-and-star skill installed at ${INSTALLED_GITHUB_SKILL}."
else
  echo "WARNING: bundled GitHub search-and-star skill was not found in the image." >&2
fi

# One-time ownership migration for existing root-owned Railway Volume data.
# --no-dereference prevents traversing symlinks inside the user data tree.
chown -R --no-dereference hermes:hermes "${HERMES_HOME}" "${HERMES_RUNTIME_DIR}" "${UV_CACHE_DIR}" /data /home/hermes
chmod 0700 "${HERMES_HOME}" /home/hermes "${UV_CACHE_DIR}"
chmod 0770 /data
chmod 0750 "${HERMES_RUNTIME_DIR}"

echo "Starting Ubuntu + Hermes terminal as non-root UID 10001 on port ${PORT}."
echo "Hermes data remains in ${HERMES_HOME}; rebuildable tools remain outside the Railway Volume."

exec /usr/bin/setpriv --reuid=hermes --regid=hermes --init-groups /usr/bin/python3 /usr/local/bin/service-supervisor.py
