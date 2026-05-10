# [[ $- != *i* ]] && return
# eval "$(ssh-agent -s)"
# export PATH="/opt:$PATH"
export REPO="$HOME/git"


alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias n='nvim'

alias la='ls -a'
alias ll='ls -l'

alias display_refresh='xrandr --auto && arandr'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash

[[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

# One-tab completion menu
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

# bash_history tweaks
shopt -s histappend
export HISTCONTROL=ignoreboth
export HISTIGNORE="ls:cd:pwd:exit:history"
export HISTSIZE=100000
export HISTFILESIZE=1000000




parse_git_branch() {
  # Get current branch name
  local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  
  if [ -n "$branch" ]; then
    local markers=""
    # Check ahead/behind remote (↑ for push needed, ↓ for pull needed)
    if git rev-parse --abbrev-ref --symbolic-full "@{u}" >/dev/null 2>&1; then
      local ahead=$(git rev-list "${branch}..@{u}" 2>/dev/null | wc -l)
      local behind=$(git rev-list "@{u}..${branch}" 2>/dev/null | wc -l)
      
      [ "$ahead" -gt 0 ] && markers+="↑"
      [ "$behind" -gt 0 ] && markers+="↓"
    fi
    
    # Add dirty indicator (✗ if uncommitted changes)
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      markers+="✗"
    fi
    
    echo "($branch$markers)"
  fi
}

PS1="\[\e[32m\]\u@\h\[\e[m\] \[\e[34m\]\w\[\e[m\] \[\e[33m\]\$(parse_git_branch)\[\e[m\] \$ "

repo() {
  cd "$REPO/$1" || return
}

builder() {
  cd "$HOME/git/isotek-builder/" || return
  scons -j15 debug=1
  cd - >/dev/null
}


_repo_complete() {
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -d -- "$REPO/$cur" | sed "s|^$REPO/||") )
}

complete -o nospace -F _repo_complete repo



. "$HOME/.local/bin/env"
