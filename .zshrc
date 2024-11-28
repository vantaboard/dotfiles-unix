# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/brighten-tompkins/.zsh/completions:"* ]]; then export FPATH="/home/brighten-tompkins/.zsh/completions:$FPATH"; fi
source ~/.zplug/init.zsh

NVIM_ALIAS="/usr/local/bin/nvim"
GIT_ALIAS="git"
nvim_cfg_alias="GIT_DIR=$HOME/.cfg GIT_WORK_TREE=$HOME /usr/local/bin/nvim"
git_cfg_alias="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

zplug "marlonrichert/zsh-edit"

zplug "vantaboard/commitizen-deno"
zplug "g-plane/zsh-yarn-autocompletions", hook-build:"./zplug.zsh", defer:2
zplug "chrissicool/zsh-256color"
zplug "redxtech/zsh-aur-install"
zplug "mollifier/cd-gitroot"
zplug "pschmitt/emoji-fzf.zsh"
zplug "QuarticCat/zsh-smartcache"
zplug "aubreypwd/zsh-plugin-fd"
zplug "urbainvaes/fzf-marks"
zplug "marlonrichert/zsh-edit"
zplug "wfxr/forgit", defer:2
zplug "Aloxaf/fzf-tab", defer:2
zplug "zdharma-continuum/fast-syntax-highlighting", defer:3

zplug check || zplug install
zplug load

# Append a command directly
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export ZSH="$HOME/.oh-my-zsh"

/usr/bin/keychain --quiet $HOME/.ssh/id_ed25519
source $HOME/.keychain/`hostname`-sh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#868888,bold"
ZSH_AUTOSUGGEST_MANUAL_REBIND=true
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="clean"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HYPHEN_INSENSITIVE="true"
MENU_COMPLETE="true"
DISABLE_UPDATE_PROMPT="true"
DIRSTACKSIZE=100000000000000000
DISABLE_MAGIC_FUNCTIONS=true

plugins=(codeclimate colored-man-pages common-aliases deno dirhistory emoji encode64 extract fzf kubectl git-auto-fetch git-escape-magic git-extras github gitignore grunt gulp isodate pip pipenv pyenv pylint python rsync virtualenv dirhistory dirpersist safe-paste zsh-autosuggestions gcloud)

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

bindkey -r ^s

source $HOME/zsh-abbr/zsh-abbr.zsh

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

eval $(keychain --quiet --eval --agents gpg $GIT_GPG_KEY)
source $HOME/.keychain/`hostname`-sh-gpg

autoload -U +X bashcompinit && bashcompinitcompinit=1

# Write to history immediately
setopt inc_append_history
# History shared among terminals
setopt share_history
# Save extended info in history
setopt extended_history
# Ignore duplicates
setopt hist_ignoredups

# disable sort when completing `git checkout`                                                                                                                                                                          
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

bindkey ^j autosuggest-accept

bindkey '^[OA' up-line-or-history
bindkey '^[OB' down-line-or-history

export TMOUT=0

PATH="/home/brighten-tompkins/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/brighten-tompkins/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/brighten-tompkins/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/brighten-tompkins/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/brighten-tompkins/perl5"; export PERL_MM_OPT;
. "/home/brighten-tompkins/.deno/env"
