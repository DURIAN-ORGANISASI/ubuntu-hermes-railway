# syntax=docker/dockerfile:1.7
FROM ubuntu:26.04
ARG DEBIAN_FRONTEND=noninteractive
ARG TTYD_VERSION=1.7.7
ARG HERMES_VERSION=0.23.1
ARG HERMES_COMMIT=3b421578588243f920886e6fe79a6faa87ea026e
ARG TARGETARCH

ENV TZ=Asia/Jakarta \
    PORT=8080 \
    PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin" \
    HERMES_HOME=/opt/data \
    HERMES_RUNTIME_DIR=/usr/local/share/hermes-tools \
    UV_CACHE_DIR=/tmp/uv-cache \
    HERMES_AUTOSTART=true \
    HERMES_VERSION=${HERMES_VERSION}

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl coreutils procps sed git tar tzdata libatomic1 \
    python3 python3-venv python3-pip \
    build-essential pkg-config libffi-dev libssl-dev xz-utils \
    passwd util-linux \
    && (apt-get install -y --no-install-recommends fastfetch || true) \
    && ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime \
    && printf '%s\n' "${TZ}" > /etc/timezone \
    && groupadd --gid 10001 hermes \
    && useradd --uid 10001 --gid 10001 --create-home --home-dir /home/hermes --shell /bin/bash hermes \
    && install -d --owner=hermes --group=hermes --mode=0770 /data \
    && install -d --owner=hermes --group=hermes --mode=0700 /opt/data \
    && install -d --owner=hermes --group=hermes --mode=0750 /usr/local/share/hermes-tools \
    && install -d --owner=hermes --group=hermes --mode=0700 /tmp/uv-cache

RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) TTYD_ASSET="ttyd.x86_64" ;; \
      arm64) TTYD_ASSET="ttyd.aarch64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/${TTYD_ASSET}" -o /usr/local/bin/ttyd; \
    chmod 0755 /usr/local/bin/ttyd; \
    /usr/local/bin/ttyd --version

# Pin both the Hermes installer source and the exact upstream release commit.
# Persistent config stays in HERMES_HOME; rebuildable PM tools/caches stay outside the Volume.
RUN --mount=type=cache,target=/tmp/uv-cache,sharing=locked \
    set -eux; \
    mkdir -p "${HERMES_HOME}/cache" \
      "${HERMES_RUNTIME_DIR}/installs" \
      "${HERMES_RUNTIME_DIR}/cache/uv" \
      "${HERMES_RUNTIME_DIR}/cache/partials" \
      "${HERMES_RUNTIME_DIR}/tools" \
      /usr/local/share/hermes-agent; \
    ln -s "${HERMES_RUNTIME_DIR}/installs" "${HERMES_HOME}/installs"; \
    ln -s "${HERMES_RUNTIME_DIR}/cache/uv" "${HERMES_HOME}/cache/uv"; \
    ln -s "${HERMES_RUNTIME_DIR}/cache/partials" "${HERMES_HOME}/cache/partials"; \
    ln -s "${HERMES_RUNTIME_DIR}/tools" "${HERMES_HOME}/tools"; \
    curl -fsSL "https://raw.githubusercontent.com/NousResearch/hermes-agent/${HERMES_COMMIT}/scripts/install.sh" -o /tmp/install-hermes.sh; \
    export PATH="/root/.local/bin:/root/.local/share/uv/bin:${PATH}"; \
    bash /tmp/install-hermes.sh --commit "${HERMES_COMMIT}" --dir /usr/local/share/hermes-agent --hermes-home "${HERMES_HOME}" --non-interactive --skip-browser; \
    hermes --version; \
    hermes pm install --extra messaging --extra telegram --extra discord; \
    hermes pm doctor; \
    if command -v uv >/dev/null 2>&1 && [ "$(command -v uv)" != "/usr/local/bin/uv" ]; then install -m 0755 "$(command -v uv)" /usr/local/bin/uv; fi; \
    if command -v uvx >/dev/null 2>&1 && [ "$(command -v uvx)" != "/usr/local/bin/uvx" ]; then install -m 0755 "$(command -v uvx)" /usr/local/bin/uvx; fi; \
    rm -f /tmp/install-hermes.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY start-hermes /usr/local/bin/start-hermes
COPY service-supervisor.py /usr/local/bin/service-supervisor.py
COPY system-banner.sh /etc/profile.d/00-system-banner.sh
COPY skills/github-repo-search-star /usr/local/share/ubuntu-hermes-railway/skills/github-repo-search-star

RUN chmod 0755 /usr/local/bin/entrypoint.sh /usr/local/bin/start-hermes /usr/local/bin/service-supervisor.py /etc/profile.d/00-system-banner.sh \
    && bash -n /usr/local/bin/entrypoint.sh /usr/local/bin/start-hermes /etc/profile.d/00-system-banner.sh \
    && python3 -m py_compile /usr/local/bin/service-supervisor.py /usr/local/share/ubuntu-hermes-railway/skills/github-repo-search-star/scripts/search_and_star.py \
    && chmod 0755 /usr/local/share/ubuntu-hermes-railway/skills/github-repo-search-star/scripts/search_and_star.py \
    && chown -R hermes:hermes /opt/data /usr/local/share/hermes-tools /data /home/hermes /tmp/uv-cache \
    && chmod 0700 /opt/data /home/hermes /tmp/uv-cache \
    && chmod 0770 /data \
    && chmod 0750 /usr/local/share/hermes-tools

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
