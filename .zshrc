source ~/.zplug/init.zsh

GPG_TTY=$(tty)
export GPG_TTY

NVIM_ALIAS="/usr/local/bin/nvim"
GIT_ALIAS="git"
nvim_cfg_alias="GIT_DIR=$HOME/.cfg GIT_WORK_TREE=$HOME /usr/local/bin/nvim"
git_cfg_alias="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

zplug "marlonrichert/zsh-edit"
zplug "g-plane/zsh-yarn-autocompletions", hook-build:"./zplug.zsh", defer:2
zplug "chrissicool/zsh-256color"
zplug "redxtech/zsh-aur-install"
zplug "mollifier/cd-gitroot"
zplug "pschmitt/emoji-fzf.zsh"
zplug "QuarticCat/zsh-smartcache"
zplug "aubreypwd/zsh-plugin-fd"
zplug "urbainvaes/fzf-marks"
zplug "sobolevn/wakatime-zsh-plugin"
zplug "olets/zsh-abbr"
zplug "marlonrichert/zsh-edit"
zplug "wfxr/forgit", defer:2
zplug "Aloxaf/fzf-tab", defer:2
zplug "zdharma-continuum/fast-syntax-highlighting", defer:3
zplug "zsh-users/zsh-autosuggestions", defer:3

zplug check || zplug install
zplug load

# Append a command directly
[[ -f $HOME/.fzf.zsh ]] && source $HOME/.fzf.zsh
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export ZSH="$HOME/.oh-my-zsh"

[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# keychain --quiet $HOME/.ssh/id_ed25519
# [[ -f "$HOME/.keychain/`hostname`-sh" ]] && source $HOME/.keychain/`hostname`-sh

ZSH_DISABLE_COMPFIX=true
ZSH_THEME="frontcube"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HYPHEN_INSENSITIVE="true"
MENU_COMPLETE="true"
DISABLE_UPDATE_PROMPT="true"

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

# eval $(keychain --quiet --eval --agents gpg $GIT_GPG_KEY)
# [[ -f $HOME/.keychain/`hostname`-sh-gpg ]] && source $HOME/.keychain/`hostname`-sh-gpg

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
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

bindkey "$terminfo[kcuu1]" up-history
bindkey "$terminfo[kcud1]" down-history


PATH="/data/data/com.termux/files/home/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/data/data/com.termux/files/home/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/data/data/com.termux/files/home/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/data/data/com.termux/files/home/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/data/data/com.termux/files/home/perl5"; export PERL_MM_OPT;
