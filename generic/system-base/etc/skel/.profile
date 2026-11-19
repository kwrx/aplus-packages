export TERMINFO=/usr/share/terminfo
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias open='aplus-xopen'
