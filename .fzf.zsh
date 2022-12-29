# Setup fzf
# ---------
if [[ ! "$PATH" == */home/blackboardd/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/blackboardd/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/blackboardd/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/blackboardd/.fzf/shell/key-bindings.zsh"
