# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="cookie"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    safe-paste
    autoswitch_virtualenv
    zsh-syntax-highlighting
    zsh-autosuggestions
    git
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# ===================== path add ====================================

# local bin {
    export PATH=$PATH:$HOME/.local/bin
# }

# golang {
    export GOROOT=/usr/local/go
    export PATH=$PATH:$GOROOT/bin
    export GOPATH=$HOME/Env/go
    export PATH=$PATH:$GOPATH/bin
# }

# rust {
    export PATH=$PATH:$HOME/.cargo/bin
# }

# fd {
    export PATH=$PATH:/usr/local/fd
# }

# ===================== lazyload assets ====================================
my_lazyload_add_command() {
    local command_name=$1
    eval "${command_name}() { \
        unfunction ${command_name}; \
        _my_lazyload_command_${command_name}; \
        ${command_name} \"\$@\"; \
    }"
}

my_lazyload_add_comp() {
    local command_name=$1
    local comp_name="_my_lazyload__compfunc_${command_name}"
    eval "${comp_name}() { \
        compdef -d ${comp_name}; \
        unfunction ${comp_name}; \
        _my_lazyload_comp_${command_name}; \
    }"
    compdef $comp_name $command_name
}

# ======================== alias ========================================
alias tp=telepresence
alias cg=codegpt
alias vim=nvim
alias vi=nvim
alias open=xdg-open
alias fastapi=fastapi_template
export NVIM=/usr/local/nvim
export PATH=$NVIM/bin:$PATH

# =================== plugin setting ====================================
# autojump config
eval "$(zoxide init --cmd j zsh)"

# zsh-autosuggest
bindkey '^O' autosuggest-accept # ctrl+Y: accept the suggest

# =================== lazyload ====================================

# kubectl
_my_lazyload_comp_kubectl() {
    source <(kubectl completion zsh)
}
my_lazyload_add_comp kubectl

# helm
_my_lazyload_comp_helm() {
    source <(helm completion zsh)
}
my_lazyload_add_comp helm

# pyenv
_my_lazyload_command_pyenv(){
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    export PYTHON_BUILD_CACHE_PATH="$PYENV_ROOT/cache"
}
my_lazyload_add_command pyenv

# java {

    # sdkman
    _my_lazyload_command_sdk(){
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    }
    my_lazyload_add_command sdk


    # java
    _my_lazyload_command_java(){
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    }
    my_lazyload_add_command java


    # spring
    _my_lazyload_command_spring(){
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    }
    my_lazyload_add_command spring

# }

# fnm
_my_lazyload_command_fnm(){
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "`fnm env`"
    autoload -U compinit; compinit
}
my_lazyload_add_command fnm
