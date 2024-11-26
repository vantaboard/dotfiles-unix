# Setup fzf
# ---------
if [[ ! "$PATH" == */home/brighten-tompkins/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/brighten-tompkins/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/brighten-tompkins/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/brighten-tompkins/.fzf/shell/key-bindings.zsh"
