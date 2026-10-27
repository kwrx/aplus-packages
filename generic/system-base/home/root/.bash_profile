if [ -n "$BASH_VERSION" ]; then
    PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
    __osc() {
        printf '\e]7;file://%s%s\e\\' "$HOSTNAME" "$PWD"
        printf '\e]0;%s@%s: %s\e\\' "$USER" "$HOSTNAME" "${PWD##*/}"
    }
    PROMPT_COMMAND+=(__osc)
fi

export TERMINFO=/usr/share/terminfo
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias open='aplus-xopen'
