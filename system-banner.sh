#!/usr/bin/env bash
# Neofetch-inspired Ubuntu + Hermes login banner for the Railway browser terminal.
# The shell, terminal server, authentication and Hermes startup remain unchanged.
[[ $- == *i* ]] || return 0
[[ -n "${UBUNTU_BANNER_SHOWN:-}" ]] && return 0
export UBUNTU_BANNER_SHOWN=1

C_ORANGE=$'\033[38;2;233;84;32m'
C_AUBERGINE=$'\033[38;2;119;33;111m'
C_VIOLET=$'\033[38;2;157;123;255m'
C_CYAN=$'\033[38;2;81;205;218m'
C_GREEN=$'\033[38;2;91;214;145m'
C_WHITE=$'\033[1;97m'
C_MUTED=$'\033[38;2;128;145;163m'
C_RESET=$'\033[0m'

. /etc/os-release 2>/dev/null || true
OS_NAME="${PRETTY_NAME:-Ubuntu}"
ARCH="$(uname -m 2>/dev/null || echo unknown)"
KERNEL="$(uname -r 2>/dev/null || echo unknown)"
UPTIME="$(uptime -p 2>/dev/null | sed 's/^up //' || echo unknown)"
CPU_COUNT="$(nproc 2>/dev/null || echo unknown)"
CPU_MODEL="$(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null)"
MEM_TOTAL="$(awk '/MemTotal/ {printf "%.1f GiB", $2/1048576}' /proc/meminfo 2>/dev/null)"
MEM_AVAIL="$(awk '/MemAvailable/ {printf "%.1f GiB", $2/1048576}' /proc/meminfo 2>/dev/null)"
MEM_USED="$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if (t>0) printf "%.1f GiB", (t-a)/1048576}' /proc/meminfo 2>/dev/null)"
DISK_INFO="$(df -h /opt/data 2>/dev/null | awk 'NR==2 {printf "%s / %s (%s)", $3, $2, $5}')"
HOST_NAME="$(hostname 2>/dev/null || echo railway-container)"
BASH_LABEL="bash ${BASH_VERSION:-unknown}"
PKG_COUNT="$(dpkg-query -f='${binary:Package}\n' -W 2>/dev/null | wc -l | tr -d ' ')"

TERM_COLS="${COLUMNS:-80}"
[[ "$TERM_COLS" =~ ^[0-9]+$ ]] || TERM_COLS=80
(( TERM_COLS < 48 )) && TERM_COLS=48

# Ubuntu's compact Neofetch-style mark for narrow browser windows.
if (( TERM_COLS < 74 )); then
  LOGO=(
    '         _'
    '      ---(_)'
    '  _/  ---  \'
    ' (_) |   |'
    '   \  --- _/'
    '      ---(_)'
  )
  LOGO_COLORS=("$C_ORANGE" "$C_ORANGE" "$C_AUBERGINE" "$C_AUBERGINE" "$C_AUBERGINE" "$C_ORANGE")
else
  # Ubuntu ASCII artwork adapted from Neofetch (MIT); rendered in Ubuntu/Hermes colors.
  # Upstream: https://github.com/dylanaraps/neofetch
  LOGO=(
    '            .-/+oossssoo+\-.'
    '         ´:+ssssssssssssssssss+:`'
    '       -+ssssssssssssssssssyyssss+-'
    '     .ossssssssssssssssssdMMMNysssso.'
    '    /ssssssssssshdmmNNmmyNMMMMhssssss\'
    '   +ssssssssshmydMMMMMMMNddddyssssssss+'
    '  /sssssssshNMMMyhhyyyyhmNMMMNhssssssss\'
    ' .ssssssssdMMMNhsssssssssshNMMMdssssssss.'
    ' +sssshhhyNMMNyssssssssssssyNMMMysssssss+'
    ' ossyNMMMNyMMhsssssssssssssshmmmhssssssso'
    ' ossyNMMMNyMMhsssssssssssssshmmmhssssssso'
    ' +sssshhhyNMMNyssssssssssssyNMMMysssssss+'
    ' .ssssssssdMMMNhsssssssssshNMMMdssssssss.'
    '  \sssssssshNMMMyhhyyyyhdNMMMNhssssssss/'
    '   +ssssssssshmydMMMMMMMMddddyssssssss+'
    '    /sssssssssshdmNNNNmyNMMMMhssssss/'
    '     .osssssssssssssssssdMMMNysssso.'
    '       -+sssssssssssssssyyyssss+-'
    '         `:+ssssssssssssssssss+:`'
    '            .-/+oossssoo+/-.'
  )
  LOGO_COLORS=("$C_ORANGE" "$C_ORANGE" "$C_AUBERGINE" "$C_AUBERGINE" "$C_AUBERGINE" "$C_VIOLET" "$C_VIOLET" "$C_VIOLET" "$C_VIOLET" "$C_VIOLET" "$C_VIOLET" "$C_VIOLET" "$C_VIOLET" "$C_VIOLET" "$C_AUBERGINE" "$C_AUBERGINE" "$C_AUBERGINE" "$C_AUBERGINE" "$C_ORANGE" "$C_ORANGE")
fi

LOGO_WIDTH=0
for line in "${LOGO[@]}"; do
  ((${#line} > LOGO_WIDTH)) && LOGO_WIDTH=${#line}
done
INFO_WIDTH=$((TERM_COLS - LOGO_WIDTH - 7))
(( INFO_WIDTH > 44 )) && INFO_WIDTH=44
(( INFO_WIDTH < 23 )) && INFO_WIDTH=23
INFO_VALUE_WIDTH=$((INFO_WIDTH - 10))

# Keep individual values short enough to prevent wrapping beside the logo.
clip_value() { printf '%s' "${1:0:INFO_VALUE_WIDTH}"; }

print_info() {
  local label="$1" value="$2"
  if [[ "$label" == "TITLE" ]]; then
    printf '%s%s%s' "$C_GREEN" "${value:0:INFO_WIDTH}" "$C_RESET"
  elif [[ "$label" == "RULE" ]]; then
    printf '%s' "$C_MUTED"
    local j
    for ((j=0; j<INFO_WIDTH; j++)); do printf '─'; done
    printf '%s' "$C_RESET"
  else
    printf '%s%-9s%s %s' "$C_ORANGE" "$label" "$C_RESET" "$(clip_value "$value")"
  fi
}

print_color_blocks() {
  local i
  for i in 40 41 42 43 44 45 46 47; do printf '\033[%sm   ' "$i"; done
  printf '%s' "$C_RESET"
}

INFO_LABELS=(TITLE RULE OS Host Kernel Uptime Packages Shell Terminal CPU Memory Storage Runtime Hermes Colors)
INFO_VALUES=(
  "${USER:-root}@${HOST_NAME}"
  ""
  "${NAME:-Ubuntu} ${VERSION_ID:-} ${ARCH}"
  "Railway container"
  "$KERNEL"
  "${UPTIME:-unknown}"
  "${PKG_COUNT:-unknown} (dpkg)"
  "$BASH_LABEL"
  "ttyd / xterm.js"
  "${CPU_MODEL:-${ARCH}} (${CPU_COUNT} vCPU)"
  "${MEM_USED:-unknown} used / ${MEM_TOTAL:-unknown}"
  "${DISK_INFO:-unknown}"
  "Docker / Railway"
  "$(if pgrep -af '[h]ermes gateway run' >/dev/null 2>&1; then printf 'Gateway active'; else printf 'Gateway not detected'; fi)"
  ""
)

printf '\n'
max_lines=${#LOGO[@]}
((${#INFO_LABELS[@]} > max_lines)) && max_lines=${#INFO_LABELS[@]}
for ((i=0; i<max_lines; i++)); do
  logo_line="${LOGO[i]:-}"
  logo_color="${LOGO_COLORS[i]:-$C_ORANGE}"
  logo_pad=$((LOGO_WIDTH - ${#logo_line}))
  printf '  %s%s%s%*s   ' "$logo_color" "$logo_line" "$C_RESET" "$logo_pad" ''
  if (( i < ${#INFO_LABELS[@]} )); then
    if [[ "${INFO_LABELS[i]}" == "Colors" ]]; then
      print_color_blocks
    else
      print_info "${INFO_LABELS[i]}" "${INFO_VALUES[i]}"
    fi
  fi
  printf '\n'
done
printf '\n'

# Classic single-line shell prompt, similar to the reference screenshot.
PS1='\[\e[38;2;91;214;145m\]\u@\h\[\e[0m\]:\[\e[38;2;157;123;255m\]\w\[\e[0m\]\$ '
export PS1
