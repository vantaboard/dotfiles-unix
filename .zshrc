##### ─────────────────────────────────────────────────────────────────────────────
##### RUN FIRST: single-pass, cached completion init (no audit), correct order
##### ─────────────────────────────────────────────────────────────────────────────

# Ensure completion dirs are available *before* compinit runs
fpath+=${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Prevent Debian/Ubuntu global rc from running compinit early
export skip_global_compinit=1

# Make OMZ skip its compfix (which triggers compaudit)
export ZSH_DISABLE_COMPFIX=true

# Use a fast compdump in XDG cache
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump-${ZSH_VERSION}"
mkdir -p -- "${ZSH_COMPDUMP:h}"

# Run the real compinit once: cached (-C), skip audit (-u), custom dump (-d)
autoload -Uz compinit
compinit -C -u -d "$ZSH_COMPDUMP"

# Completion styles
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"
zstyle ':completion:*' rehash false

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

##### ─────────────────────────────────────────────────────────────────────────────
##### Manually installed plugins (source *before* OMZ is fine with the guard)
##### ─────────────────────────────────────────────────────────────────────────────

# zsh-edit
source "$HOME/.zshplugins/zsh-edit/zsh-edit.plugin.zsh"

# If you also have ~/.fzf.zsh and want it after zvm init (harmless if var unset)
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')

##### ─────────────────────────────────────────────────────────────────────────────
##### Oh My Zsh core
##### ─────────────────────────────────────────────────────────────────────────────

export ZSH="$HOME/.oh-my-zsh"

# OMZ / plugin settings
export ABBR_AUTOLOAD=0
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#868888,bold"
export ZSH_AUTOSUGGEST_MANUAL_REBIND=true
export ZSH_THEME="clean"
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export HYPHEN_INSENSITIVE="true"
export MENU_COMPLETE="true"
export DISABLE_AUTO_UPDATE=true
export DISABLE_UPDATE_PROMPT="true"
export DIRSTACKSIZE=100000000000000000
export DISABLE_MAGIC_FUNCTIONS=true

export PATH="$PATH:{KREW_ROOT:-$HOME/.krew}/bin:${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$HOME/.local/bin:$HOME/.local/share/gem/ruby/3.0.0/bin:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:$HOME/go/bin:$HOME/kde/usr/bin:$HOME/.istioctl/bin:/opt/depot_tools:/usr/local/go/bin:$HOME/.cargo/bin:$HOME/Code/splatmoji/:/opt/nvim-linux-x86_64/bin:$HOME/perl5/bin"

plugins=(codeclimate extract python virtualenv zsh-autosuggestions direnv ssh-agent fzf fzf-tab)

# OMZ bootstrap (now safe—compinit/compaudit are already handled)
source "$ZSH/oh-my-zsh.sh"

# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

##### ─────────────────────────────────────────────────────────────────────────────
##### Lazy-load abbreviations
##### ─────────────────────────────────────────────────────────────────────────────

autoload -Uz add-zsh-hook
_abbr_lazy_load() {
  add-zsh-hook -d precmd _abbr_lazy_load
  source "$HOME/zsh-abbr/zsh-abbr.zsh"
}
add-zsh-hook precmd _abbr_lazy_load

##### ─────────────────────────────────────────────────────────────────────────────
##### Source your dotfiles bundle
##### ─────────────────────────────────────────────────────────────────────────────

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

source_files() {
  local files=("$@")
  for file in "${files[@]}"; do
    [[ -r "$HOME/.$file" ]] && source "$HOME/.$file"
  done
}
source_files "${files[@]}"

##### ─────────────────────────────────────────────────────────────────────────────
##### History settings
##### ─────────────────────────────────────────────────────────────────────────────

setopt inc_append_history     # write to history immediately
setopt share_history          # share history across sessions
setopt extended_history       # save timestamp/duration
setopt hist_ignoredups        # skip duplicate commands

##### ─────────────────────────────────────────────────────────────────────────────
##### asdf-direnv, keychain, GPG
##### ─────────────────────────────────────────────────────────────────────────────

# asdf-direnv integration
source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"

# SSH keys
# /usr/bin/keychain --quiet "$HOME/.ssh/id_ed25519"
# source "$HOME/.keychain/$(hostname)-sh"

# GPG (only if you actually have $GIT_GPG_KEY set)
eval "$(keychain --quiet --eval --agents gpg "$GIT_GPG_KEY" 2>/dev/null)"  # ignore if unset
source "$HOME/.keychain/$(hostname)-sh-gpg" 2>/dev/null

##### ─────────────────────────────────────────────────────────────────────────────
##### Optional: manual recompile helper (run only when you change files)
##### ─────────────────────────────────────────────────────────────────────────────

recompile_zsh() {
  autoload -Uz zrecompile
  setopt localoptions null_glob
  local globs=(
    "$ZSH/oh-my-zsh.sh"
    "$ZSH/lib/*.zsh"
    "$ZSH/plugins/git/git.plugin.zsh"
    "$HOME/.zshplugins/zsh-edit/*.zsh"
    "$HOME/.{export,env,functions,alias,alias-git,bindings,inputrc,fzf.zsh}"
  )
  local f
  for f in ${^globs}; do
    [[ -r "$f" ]] && zrecompile -p "$f"
  done
  echo "Recompiled."
}

##### ─────────────────────────────────────────────────────────────────────────────
##### Profiling (optional)
##### ─────────────────────────────────────────────────────────────────────────────

# Comment out when you’re done profiling
# zprof

autoload -U compinit
source $HOME/.fzf-tab/fzf-tab.zsh

# Must be set *before* the init line above if you want it to apply there too,
# but it's fine after if you only care about manual calls like the widget below.
export _ZO_FZF_OPTS="--height 40% --layout=reverse --info=inline"

# replace 'cd' with zoxide's function and install hooks
eval "$(zoxide init zsh --cmd cd)"

__zox_fzf_cd_widget() {
  setopt localoptions no_shwordsplit
  zle -I  # clear pending keys

  local dir
  local exit_code

  # Use the real TTY for input so Ctrl-C cancels fzf itself
  dir="$(zoxide query -i </dev/tty 2>/dev/tty)"
  exit_code=$?

  # Ctrl-C inside fzf: just repaint a clean prompt (no literal $PROMPT echo)
  if (( exit_code == 130 )); then
    BUFFER=''            # ensure nothing remains on the line
    zle reset-prompt
    zle redisplay
    return 0
  fi

  # Esc or other nonzero → repaint and bail
  if (( exit_code != 0 )); then
    zle reset-prompt
    zle redisplay
    return 0
  fi

  [[ -n $dir ]] || { zle reset-prompt; zle redisplay; return 0; }

  # Jump immediately
  builtin cd -- "$dir" || return
  zoxide add -- "$dir" &>/dev/null
  zle reset-prompt
  zle redisplay
}

zle -N __zox_fzf_cd_widget
bindkey '^U' __zox_fzf_cd_widget
bindkey -M viins '^U' __zox_fzf_cd_widget
bindkey -M vicmd '^U' __zox_fzf_cd_widget
