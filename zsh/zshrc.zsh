# -*- mode: sh -*-

export PATH=${HOME}/bin:/usr/local/bin:/usr/local/sbin:${PATH}:.

# Path to your oh-my-zsh installation.
export ZSH=/Users/sthoden/.oh-my-zsh
export MYZSH=/Users/sthoden/myhomefiles/zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
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
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git python tmux emacs)
plugins=(git git-flow git-flow-completion python tmux docker docker-compose jhipster)

source $ZSH/oh-my-zsh.sh
source $MYZSH/alias.zsh

source $MYZSH/functions.zsh
source $MYZSH/hybris.zsh

# Shell history
HISTSIZE=1000
SAVEHIIST=2000
HISTFILE=~/.zsh_history

DIRSTACKSIZE=8
setopt autopushd pushdminus pushdsilent pushdtohome



##-----------------------------------------------------------------------------
## Current ulimit can be listed with ulimit -a
## The maximum number of open file descriptors. 
ulimit -n 20000
## The maximum number of processes available to a single user.
ulimit -u 2048

##-----------------------------------------------------------------------------
## Java
##-----------------------------------------------------------------------------
JAVA_LIB_DIR=${HOME}/java
# for Mac OS 10
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export CLASSPATH=${CLASSPATH}:.

##-----------------------------------------------------------------------------
## mysql
##-----------------------------------------------------------------------------
export PATH=${PATH}:/usr/local/mysql/bin

##-----------------------------------------------------------------------------
## apache maven
##-----------------------------------------------------------------------------
# export MAVEN_HOME=${HOME}/java/apache-maven-2.2.1
export MAVEN_OPTS="-Xms256m -Xmx1024m"
# export PATH=${MAVEN_HOME}/bin:${PATH}


# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"


