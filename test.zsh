#!/usr/bin/env zsh
# Plain-zsh checks for ssh-iterm-color. Run: zsh test.zsh  (exits non-zero on failure)

setopt extended_glob
unset ITERM_BG_COLOR SSH_BG_COLORS NO_ITERM2_INTEGRATION_HOSTS

here=${0:A:h}
plugin=${PLUGIN:-$here/ssh-iterm-color.plugin.zsh}
tmp=$(mktemp -d "${TMPDIR:-/tmp}/ssh-iterm-color-test-XXXXXX")
trap 'rm -rf -- "$tmp"' EXIT

# The plugin calls `command ssh`, which skips shell functions, so the stub is an executable on PATH.
mkdir "$tmp/bin"
cat > "$tmp/bin/ssh" <<'EOF'
#!/bin/sh
[ "$1" = -G ] && { echo "hostname example.com"; exit 0; }
exit 7
EOF
chmod +x "$tmp/bin/ssh"
export PATH="$tmp/bin:$PATH"

failures=0
fail() { print -r -u2 -- "FAIL: $*"; (( failures++ )) }
pass() { print -r -- "ok: $*" }

source "$plugin"

# 1. stdout redirected to a file: no iTerm2 escapes, exit status preserved.
TERM_PROGRAM=iTerm.app ssh_iterm_color example.com > "$tmp/out1"
st=$?
if [[ $(<"$tmp/out1") == *$'\e]1337'* ]]; then fail "redirected output contains \\e]1337"; else pass "redirected output has no \\e]1337"; fi
if (( st == 7 )); then pass "redirected: ssh exit status 7 returned"; else fail "redirected: expected status 7, got $st"; fi

# 2. tty stdout under iTerm2 (via script(1)): color + badge set, then reverted, exit status preserved.
script -q "$tmp/out2" zsh -fc '
  source "$1"
  TERM_PROGRAM=iTerm.app ssh_iterm_color example.com
  print -r -- $? > "$2"
' zsh "$plugin" "$tmp/status2" < /dev/null > /dev/null
st=$(cat "$tmp/status2" 2>/dev/null)
out=$(cat "$tmp/out2" 2>/dev/null)
if [[ $out == *$'\e]1337;SetColors=bg='[0-9a-fA-F]##$'\a'* ]]; then pass "tty: SetColors printed"; else fail "tty: SetColors not printed"; fi
if [[ $out == *$'\e]1337;SetColors=bg=default\a\e]1337;SetBadgeFormat=\a'* ]]; then pass "tty: revert printed"; else fail "tty: revert not printed"; fi
if [[ $st == 7 ]]; then pass "tty: ssh exit status 7 returned"; else fail "tty: expected status 7, got '${st}'"; fi

(( failures == 0 )) && print -- "all passed" || { print -u2 -- "$failures failed"; exit 1 }
