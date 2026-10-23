# [[ $- != *i* ]] && return
# if [ -z "$SSH_AUTH_SOCK" ]; then
#   eval "$(ssh-agent -s)"
#   ssh-add -t 28800
# fi
# export PATH="/opt:$PATH"
export REPO="$HOME/git"
export GPG_TTY=$(tty)
export PATH=$PATH:/opt/microchip/xc16/v2.10/bin/


alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias n='nvim'

alias la='ls -a'
alias ll='ls -l'
alias :q='exit'
alias pull-all='$HOME/.config/sh-scripts/pull_all.sh'
alias ssh-dell='ssh -XYC localusr@archdell'

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


port-find(){
	sudo ss -tulpn | grep :$1
	if [&2 -eq "y" ]; then
		kill -9 $1		
	fi
} 

new-checkout() {
  git checkout $1
}


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

force-sysctl() {
    if (($# != 2)); then
        printf 'Usage: force-sysctl ACTION UNIT-PATTERN\n' >&2
        return 2
    fi

    local action=$1
    local pattern=$2
    local -a units

    mapfile -t units < <(
        systemctl --user list-units \
            --all \
            --no-legend \
            --plain \
            --full \
            "$pattern" |
        awk '{ print $1 }'
    )

    if ((${#units[@]} == 0)); then
        printf 'No matching user units: %s\n' "$pattern" >&2
        return 1
    fi

    systemctl --user "$action" --now "${units[@]}"
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

export PATH="$HOME/.config/emacs/bin:$PATH"

. "$HOME/.local/bin/env"
 


# source '/home/charlie/.bash_completions/unsloth.sh'
