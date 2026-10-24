#!/usr/bin/env bash
# Modern, lightweight login banner for the Ubuntu + Hermes Railway terminal.
[[ $- == *i* ]] || return 0
[[ -n "${UBUNTU_BANNER_SHOWN:-}" ]] && return 0
export UBUNTU_BANNER_SHOWN=1

# Ubuntu orange + Hermes violet, with restrained status accents.
C_ORANGE=$'\033[38;2;233;84;32m'
C_VIOLET=$'\033[38;2;157;123;255m'
C_CYAN=$'\033[38;2;81;205;218m'
C_GREEN=$'\033[38;2;91;214;145m'
C_WHITE=$'\033[1;97m'
C_MUTED=$'\033[38;2;128;145;163m'
C_RESET=$'\033[0m'

. /etc/os-release 2>/dev/null || true
OS_NAME="${PRETTY_NAME:-Ubuntu}"
UBUNTU_VERSION="${VERSION_ID:-26.04}"
[[ "${ID:-ubuntu}" == "ubuntu" ]] || UBUNTU_VERSION=26.04
ARCH="$(uname -m 2>/dev/null || echo unknown)"
KERNEL="$(uname -r 2>/dev/null || echo unknown)"
UPTIME="$(uptime -p 2>/dev/null | sed 's/^up //' || echo unknown)"
CPU_COUNT="$(nproc 2>/dev/null || echo unknown)"
MEM_TOTAL="$(awk '/MemTotal/ {printf "%.1f GiB", $2/1048576}' /proc/meminfo 2>/dev/null)"
MEM_AVAIL="$(awk '/MemAvailable/ {printf "%.1f GiB", $2/1048576}' /proc/meminfo 2>/dev/null)"
DISK_INFO="$(df -h /data 2>/dev/null | awk 'NR==2 {printf "%s / %s (%s)", $3, $2, $5}')"
TZ_NAME="${TZ:-$(cat /etc/timezone 2>/dev/null || echo UTC)}"
HOST_NAME="$(hostname 2>/dev/null || echo railway-container)"
BASH_LABEL="Bash ${BASH_VERSION:-unknown}"

# Keep the frame within the browser terminal width, while limiting very wide banners.
TERM_COLS="${COLUMNS:-80}"
[[ "$TERM_COLS" =~ ^[0-9]+$ ]] || TERM_COLS=80
(( TERM_COLS > 78 )) && TERM_COLS=78
(( TERM_COLS < 48 )) && TERM_COLS=48
RULE_WIDTH=$((TERM_COLS - 4))
VALUE_WIDTH=$((TERM_COLS - 15))
printf -v RULE '%*s' "$RULE_WIDTH" ''
RULE="${RULE// /─}"

print_rule() {
  printf '  %s├%s┤%s\n' "$C_MUTED" "$RULE" "$C_RESET"
}

print_row() {
  local label="$1" value="$2"
  printf '  %s│%s %s%-8s%s %-*.*s %s│%s\n' \
    "$C_MUTED" "$C_RESET" "$C_CYAN" "$label" "$C_RESET" \
    "$VALUE_WIDTH" "$VALUE_WIDTH" "$value" "$C_MUTED" "$C_RESET"
}

print_plain_row() {
  local value="$1"
  printf '  %s│%s %-*.*s %s│%s\n' \
    "$C_MUTED" "$C_RESET" "$((TERM_COLS - 6))" "$((TERM_COLS - 6))" \
    "$value" "$C_MUTED" "$C_RESET"
}

printf '\n'
printf '  %s╭%s╮%s\n' "$C_MUTED" "$RULE" "$C_RESET"
if (( TERM_COLS >= 56 )); then
  BRAND_TEXT="[U]  UBUNTU ${UBUNTU_VERSION}   |   [H]  HERMES AGENT"
  SUBTITLE_TEXT='SECURE SHELL  /  AI AGENT RUNTIME  /  RAILWAY'
  BRAND_PADDING=$((TERM_COLS - 6 - ${#BRAND_TEXT}))
  printf '  %s│%s %s[U]%s  %sUBUNTU %s%s   %s|%s   %s[H]%s  %sHERMES AGENT%s%*s %s│%s\n' \
    "$C_MUTED" "$C_RESET" "$C_ORANGE" "$C_RESET" \
    "$C_WHITE" "$UBUNTU_VERSION" "$C_RESET" "$C_MUTED" "$C_RESET" \
    "$C_VIOLET" "$C_RESET" "$C_WHITE" "$C_RESET" \
    "$BRAND_PADDING" '' "$C_MUTED" "$C_RESET"
else
  BRAND_TEXT='[U] UBUNTU  |  [H] HERMES'
  SUBTITLE_TEXT='SHELL / AI AGENT / RAILWAY'
  BRAND_PADDING=$((TERM_COLS - 6 - ${#BRAND_TEXT}))
  printf '  %s│%s %s[U]%s %sUBUNTU%s  %s|%s  %s[H]%s %sHERMES%s%*s %s│%s\n' \
    "$C_MUTED" "$C_RESET" "$C_ORANGE" "$C_RESET" "$C_WHITE" "$C_RESET" \
    "$C_MUTED" "$C_RESET" "$C_VIOLET" "$C_RESET" "$C_WHITE" "$C_RESET" \
    "$BRAND_PADDING" '' "$C_MUTED" "$C_RESET"
fi
print_plain_row "$SUBTITLE_TEXT"
print_rule
print_row "HOST" "${USER:-root}@${HOST_NAME}"
print_row "SHELL" "$BASH_LABEL"
print_row "PLATFORM" "$OS_NAME / $ARCH / kernel $KERNEL"
print_row "UPTIME" "${UPTIME:-unknown} / ${CPU_COUNT} vCPU(s)"
print_row "MEMORY" "${MEM_AVAIL:-unknown} available / ${MEM_TOTAL:-unknown} total"
print_row "STORAGE" "${DISK_INFO:-unknown} on /data"
print_row "TIMEZONE" "$TZ_NAME"
print_rule
if pgrep -af '[h]ermes gateway run' >/dev/null 2>&1; then
  print_row "GATEWAY" "[ON] ACTIVE - Hermes Gateway process detected"
else
  print_row "GATEWAY" "[OFF] NOT DETECTED - run hermes setup"
fi
printf '  %s╰%s╯%s\n' "$C_MUTED" "$RULE" "$C_RESET"
if (( TERM_COLS >= 62 )); then
  printf '  %sHELP%s  %shermes --help%s     %sSETUP%s  %shermes setup%s     %sPATH%s  %s/data%s\n\n' \
    "$C_MUTED" "$C_RESET" "$C_VIOLET" "$C_RESET" "$C_MUTED" "$C_RESET" \
    "$C_VIOLET" "$C_RESET" "$C_MUTED" "$C_RESET" "$C_CYAN" "$C_RESET"
else
  printf '  %sHELP%s  %shermes --help%s  |  %shermes setup%s\n\n' \
    "$C_MUTED" "$C_RESET" "$C_VIOLET" "$C_RESET" "$C_VIOLET" "$C_RESET"
fi

# A clean two-line prompt: muted host, violet working directory, Ubuntu-orange command marker.
PS1='\[\e[38;2;128;145;163m\]\u@\h \[\e[38;2;157;123;255m\]\w\[\e[0m\]\n\[\e[38;2;233;84;32m\]❯ \[\e[0m\]'
export PS1
