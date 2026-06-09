# Setup fzf
# ---------
if [[ ! "$PATH" == */home/charlie/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/charlie/.fzf/bin"
fi

eval "$(fzf --bash)"
