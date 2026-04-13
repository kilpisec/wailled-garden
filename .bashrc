# .bashrc for agent container

# Source global definitions if they exist
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Source uv environment
if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

# User specific aliases and functions

# Alias for codex (with wrapper for device auth support)
alias codex='/opt/agent-base-image/codex-wrapper.sh'

# Set a nice prompt
export PS1='\u@\h:\w\$ '

# Add common helpful settings
export EDITOR=vim
export VISUAL=vim

# Enable color support
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# add bun to path
export PATH="${PATH}:~/.bun/bin"

# add claude to path
export PATH="$HOME/.local/bin:$PATH"

# add golang to path
export PATH="/usr/local/go/bin:$PATH"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
