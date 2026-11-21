export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

case $- in
    *i*) ;;
    *) return ;;
esac

if [ -n "$BASH_VERSION" ]; then
    PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
    __osc() {
        printf '\e]7;file://%s%s\e\\' "$HOSTNAME" "$PWD"
        printf '\e]0;%s@%s: %s\e\\' "$USER" "$HOSTNAME" "${PWD##*/}"
    }
    PROMPT_COMMAND+=(__osc)

    HISTCONTROL=ignoreboth
    HISTSIZE=1000
    HISTFILESIZE=2000
    shopt -s histappend checkwinsize
fi

alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias open='aplus-xopen'
