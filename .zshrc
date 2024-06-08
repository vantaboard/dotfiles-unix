source ~/.zplug/init.zsh

NVIM_ALIAS="/usr/local/bin/nvim"
GIT_ALIAS="git"
nvim_cfg_alias="GIT_DIR=$HOME/.cfg GIT_WORK_TREE=$HOME /usr/local/bin/nvim"
git_cfg_alias="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

zplug "marlonrichert/zsh-edit"

# git config --global alias.cz '$HOME/.zplug/repos/vantaboard/commitizen-deno/commitizen-deno --'
zplug "vantaboard/commitizen-deno"
zplug "g-plane/zsh-yarn-autocompletions", hook-build:"./zplug.zsh", defer:2
zplug "chrissicool/zsh-256color"
zplug "redxtech/zsh-aur-install"
zplug "mollifier/cd-gitroot"
zplug "pschmitt/emoji-fzf.zsh"
zplug "QuarticCat/zsh-smartcache"
zplug "aubreypwd/zsh-plugin-fd"
zplug "urbainvaes/fzf-marks"
zplug "olets/zsh-abbr"
zplug "marlonrichert/zsh-edit"
zplug "wfxr/forgit", defer:2
zplug "Aloxaf/fzf-tab", defer:2
zplug "zdharma-continuum/fast-syntax-highlighting", defer:3
zplug "zsh-users/zsh-autosuggestions", defer:3

zplug check || zplug install
zplug load

# Append a command directly
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')

[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/nvm.sh
source /usr/share/nvm/bash_completion
source /usr/share/nvm/install-nvm-exec

export ZSH="$HOME/.oh-my-zsh"

[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

/usr/bin/keychain --quiet $HOME/.ssh/id_ed25519
source $HOME/.keychain/`hostname`-sh

ZSH_DISABLE_COMPFIX=true
ZSH_THEME="frontcube"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HYPHEN_INSENSITIVE="true"
MENU_COMPLETE="true"
DISABLE_UPDATE_PROMPT="true"
DIRSTACKSIZE=100000000000000000

plugins=(codeclimate colored-man-pages common-aliases deno dirhistory emoji encode64 extract fd fzf kubectl git-auto-fetch git-escape-magic git-extras github gitignore grunt gulp isodate pip pipenv pyenv pylint python ripgrep rsync virtualenv zsh-autosuggestions dirhistory dirpersist)

bindkey -r ^s
bindkey ^j autosuggest-accept

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

declare -a files=(
    "export"
    "env"
    "functions"
    "alias"
    "alias-git"
    "bindings"
    "inputrc"
    "fzf.zsh"
)

function source_files {
    files=("$@")

    for file in "${files[@]}"
    do
        source "$HOME/.$file"
    done
}

source_files $files

eval $(thefuck --alias)
eval $(keychain --quiet --eval --agents gpg $GIT_GPG_KEY)
source $HOME/.keychain/`hostname`-sh-gpg

export WORKON_HOME=~/.virtualenvs
source /usr/bin/virtualenvwrapper.sh

# kdesrc-build #################################################################

## Add kdesrc-build to PATH
export PATH="$HOME/kde/src/kdesrc-build:$PATH"


## Autocomplete for kdesrc-run
function _comp_kdesrc_run
{
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Complete only the first argument
    if [[ $COMP_CWORD != 1 ]]; then
        return 0
    fi

    # Retrieve build modules through kdesrc-run
    # If the exit status indicates failure, set the wordlist empty to avoid
    # unrelated messages.
    local modules
    if ! modules=$(kdesrc-run --list-installed);
    then
        modules=""
    fi

    # Return completions that match the current word
    COMPREPLY=( $(compgen -W "${modules}" -- "$cur") )

    return 0
}

## Register autocomplete function
complete -o nospace -F _comp_kdesrc_run kdesrc-run

################################################################################

autoload -U +X bashcompinit && bashcompinitcompinit=1

# pnpm
export PNPM_HOME="/home/blackboardd/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Write to history immediately
setopt inc_append_history
# History shared among terminals
setopt share_history
# Save extended info in history
setopt extended_history
# Ignore duplicates
setopt hist_ignoredups

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/blackboardd/Code/google-cloud-sdk/path.zsh.inc' ]; then . '/home/blackboardd/Code/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/blackboardd/Code/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/blackboardd/Code/google-cloud-sdk/completion.zsh.inc'; fi

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
