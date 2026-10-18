FROM ubuntu:26.04
ARG DEBIAN_FRONTEND=noninteractive
ARG TTYD_VERSION=1.7.7
ARG TARGETARCH

# Keep Hermes package-manager runtimes outside HERMES_HOME. Railway's /opt/data
# volume may be only 500 MB; Python/Node/FFmpeg managed tools must not fill it.
ENV TZ=Asia/Jakarta \
    PORT=8080 \
    PATH="/root/.local/bin:/root/.local/share/uv/bin:/usr/local/bin:/usr/bin:/bin" \
    HERMES_HOME=/opt/data \
    HERMES_RUNTIME_DIR=/usr/local/share/hermes-tools \
    UV_CACHE_DIR=/tmp/uv-cache \
    HERMES_AUTOSTART=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl coreutils procps sed git \
    python3 python3-venv python3-pip \
    build-essential pkg-config libffi-dev libssl-dev xz-utils \
    && (apt-get install -y --no-install-recommends fastfetch || true) \
    && rm -rf /var/lib/apt/lists/*

# Download ttyd for the target architecture.
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) TTYD_ASSET="ttyd.x86_64" ;; \
      arm64) TTYD_ASSET="ttyd.aarch64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/${TTYD_ASSET}" -o /usr/local/bin/ttyd; \
    chmod +x /usr/local/bin/ttyd; \
    /usr/local/bin/ttyd --version

# Install Hermes into the image at build time. HERMES_HOME is only for persistent
# user config/state; HERMES_RUNTIME_DIR keeps managed tools off the small volume.
RUN mkdir -p "${HERMES_RUNTIME_DIR}" "${HERMES_HOME}" \
    && curl -fsSL https://hermes-agent.nousresearch.com/install.sh -o /tmp/install-hermes.sh \
    && env -u HERMES_HOME bash /tmp/install-hermes.sh --non-interactive --skip-browser \
    && rm -f /tmp/install-hermes.sh \
    && command -v hermes

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY system-banner.sh /etc/profile.d/00-system-banner.sh
COPY start-hermes /usr/local/bin/start-hermes

RUN chmod 0755 /usr/local/bin/entrypoint.sh /usr/local/bin/start-hermes /etc/profile.d/00-system-banner.sh \
    && mkdir -p /data /opt/data /usr/local/share/hermes-tools \
    && chmod 0777 /data \
    && chmod 0755 /opt/data /usr/local/share/hermes-tools

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
