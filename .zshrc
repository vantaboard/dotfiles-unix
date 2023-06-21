source ~/.zplug/init.zsh

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

skip_global_compinit=1
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="frontcube"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HYPHEN_INSENSITIVE="true"
MENU_COMPLETE="true"
DISABLE_UPDATE_PROMPT="true"

plugins=(codeclimate colored-man-pages common-aliases deno dirhistory emoji encode64 extract fd fzf kubectl git-auto-fetch git-escape-magic git-extras github gitignore grunt gulp isodate pip pipenv pyenv pylint python ripgrep rsync virtualenv zsh-autosuggestions)

bindkey -r ^s
bindkey ^j autosuggest-accept

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

declare -a files=(
  "export"
  "env"
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
