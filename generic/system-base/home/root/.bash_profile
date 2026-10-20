if [ -n "$BASH_VERSION" ]; then
    PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
fi

export TERMINFO=/usr/share/terminfo
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias open='aplus-xopen'