# Configuration Variables:
# SSH_BG_COLORS: A space-separated list of color codes to be used for the terminal background. If not set, defaults to a predefined list of colors.
# ITERM_BG_COLOR: The iTerm background color to revert to after ssh exits. If not set, defaults to `default` (the profile's background).
# NO_ITERM2_INTEGRATION_HOSTS: An array of hostnames for which iTerm2 integration (color change, badge setting) should be skipped.

function change_look() {
    local hostname=$1
    local hash=$(printf '%s' "$hostname" | md5 -q 2>/dev/null || printf '%s' "$hostname" | md5sum)

    [[ -n $hash ]] || return 1

    local colors=(${=SSH_BG_COLORS:-301 130 013 310})
    local num_colors=${#colors[@]}
    local hash_prefix=${hash:0:8}
    local color_index=$((16#$hash_prefix % num_colors + 1))
    local selected_color=${colors[$color_index]}

    printf '\e]1337;SetColors=bg=%s\a' "${selected_color:-default}"
    printf '\e]1337;SetBadgeFormat=%s\a' "$(echo -n "$hostname" | base64)"
}

function revert_look() {
    printf '\e]1337;SetColors=bg=%s\a' ${ITERM_BG_COLOR:-default}
    printf '\e]1337;SetBadgeFormat=\a'
}

function ssh_iterm_color() {
    local hostname=$(command ssh -G "$@" 2>/dev/null | awk '/^hostname /{print $2; exit}')

    # escapes would corrupt piped/redirected output, and only iTerm understands them
    if [[ ! -t 1 || $TERM_PROGRAM != iTerm.app ]] || (( ${NO_ITERM2_INTEGRATION_HOSTS[(Ie)$hostname]} )); then
        command ssh "$@"
        return
    fi

    change_look "$hostname"
    { command ssh "$@" } always { revert_look }
}
