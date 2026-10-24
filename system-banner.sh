#!/usr/bin/env bash
# Branded, lightweight login banner for the Ubuntu + Hermes Railway terminal.
[[ $- == *i* ]] || return 0
[[ -n "${UBUNTU_BANNER_SHOWN:-}" ]] && return 0
export UBUNTU_BANNER_SHOWN=1

# ANSI true-colour palette: Ubuntu orange, Hermes violet, and calm terminal cyan.
C_ORANGE=$'\033[38;2;233;84;32m'
C_VIOLET=$'\033[38;2;157;123;255m'
C_CYAN=$'\033[38;2;81;205;218m'
C_GREEN=$'\033[38;2;91;214;145m'
C_RED=$'\033[38;2;255;107;107m'
C_WHITE=$'\033[1;97m'
C_MUTED=$'\033[38;2;128;145;163m'
C_RESET=$'\033[0m'

. /etc/os-release 2>/dev/null || true
OS_NAME="${PRETTY_NAME:-Ubuntu}"
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

printf '\n'
printf '%s╭──────────────────────────────────────────────────────────────────────────────╮%s\n' "$C_MUTED" "$C_RESET"
printf '%s│%s  %s☿%s  %sHERMES AGENT%s                         %s● ◉ ●%s  %sUBUNTU 26.04%s          %s│%s\n' \
  "$C_MUTED" "$C_RESET" "$C_VIOLET" "$C_RESET" "$C_WHITE" "$C_RESET" "$C_ORANGE" "$C_RESET" "$C_WHITE" "$C_RESET" "$C_MUTED" "$C_RESET"
printf '%s│%s     %sAI AGENT RUNTIME%s  %s·%s  %sBROWSER TERMINAL%s  %s·%s  %sRAILWAY%s         %s│%s\n' \
  "$C_MUTED" "$C_RESET" "$C_VIOLET" "$C_RESET" "$C_MUTED" "$C_RESET" "$C_CYAN" "$C_RESET" "$C_MUTED" "$C_RESET" "$C_ORANGE" "$C_RESET" "$C_MUTED" "$C_RESET"
printf '%s├──────────────────────────────────────────────────────────────────────────────┤%s\n' "$C_MUTED" "$C_RESET"

printf '%s│%s  %s%-8s%s %-25.25s   %s%-8s%s %-26.26s    %s│%s\n' \
  "$C_MUTED" "$C_RESET" "$C_CYAN" "HOST" "$C_RESET" "${USER:-root}@${HOST_NAME}" \
  "$C_CYAN" "KERNEL" "$C_RESET" "$KERNEL" "$C_MUTED" "$C_RESET"
printf '%s│%s  %s%-8s%s %-25.25s   %s%-8s%s %-26.26s    %s│%s\n' \
  "$C_MUTED" "$C_RESET" "$C_CYAN" "SHELL" "$C_RESET" "$BASH_LABEL" \
  "$C_CYAN" "ARCH" "$C_RESET" "$ARCH" "$C_MUTED" "$C_RESET"
printf '%s│%s  %s%-8s%s %-25.25s   %s%-8s%s %-26.26s    %s│%s\n' \
  "$C_MUTED" "$C_RESET" "$C_CYAN" "UPTIME" "$C_RESET" "${UPTIME:-unknown}" \
  "$C_CYAN" "CPU" "$C_RESET" "${CPU_COUNT} vCPU(s)" "$C_MUTED" "$C_RESET"
printf '%s│%s  %s%-8s%s %-25.25s   %s%-8s%s %-26.26s    %s│%s\n' \
  "$C_MUTED" "$C_RESET" "$C_CYAN" "MEMORY" "$C_RESET" "${MEM_AVAIL:-unknown} free / ${MEM_TOTAL:-unknown}" \
  "$C_CYAN" "DISK" "$C_RESET" "${DISK_INFO:-unknown}" "$C_MUTED" "$C_RESET"
printf '%s│%s  %s%-8s%s %-25.25s   %s%-8s%s %-26.26s    %s│%s\n' \
  "$C_MUTED" "$C_RESET" "$C_CYAN" "TIMEZONE" "$C_RESET" "$TZ_NAME" \
  "$C_CYAN" "OS" "$C_RESET" "$OS_NAME" "$C_MUTED" "$C_RESET"

printf '%s├──────────────────────────────────────────────────────────────────────────────┤%s\n' "$C_MUTED" "$C_RESET"
if pgrep -af '[h]ermes gateway run' >/dev/null 2>&1; then
  printf '%s│%s  %s●%s  %sHERMES GATEWAY%s  %sRUNNING%s                                      %s│%s\n' \
    "$C_MUTED" "$C_RESET" "$C_GREEN" "$C_RESET" "$C_WHITE" "$C_RESET" "$C_GREEN" "$C_RESET" "$C_MUTED" "$C_RESET"
else
  printf '%s│%s  %s○%s  %sHERMES GATEWAY%s  %sNOT RUNNING · SETUP MAY BE NEEDED%s          %s│%s\n' \
    "$C_MUTED" "$C_RESET" "$C_ORANGE" "$C_RESET" "$C_WHITE" "$C_RESET" "$C_ORANGE" "$C_RESET" "$C_MUTED" "$C_RESET"
fi
printf '%s╰──────────────────────────────────────────────────────────────────────────────╯%s\n' "$C_MUTED" "$C_RESET"
printf '  %sTip:%s run %shermes --help%s to explore the CLI, or %shermes setup%s to configure it.\n\n' \
  "$C_MUTED" "$C_RESET" "$C_VIOLET" "$C_RESET" "$C_VIOLET" "$C_RESET"
