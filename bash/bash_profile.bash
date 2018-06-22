##=============================================================================
##
## Author: Sven Thoden
##_____________________________________________________________________________
##
## Usage: / 
##
## Description: 
##      Sventes bash settings
##=============================================================================

# add home/bin to path
export PATH=${HOME}/bin:/usr/local/bin:/usr/local/sbin:${PATH}
# export PS1="\w> "

# highlight $HOST:$PWD prompt
export PS1='\[\e[1m\]\h:\w\$\[\e[0m\] '

# Don't store duplicate adjacent items in the history
HISTCONTROL=ignoreboth

# Make and change to a directory
md () { mkdir -p "$1" && cd "$1"; }

##-----------------------------------------------------------------------------
## Java 
##-----------------------------------------------------------------------------
JAVA_LIB_DIR=${HOME}/java

# for Mac OS 10
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export CLASSPATH=${CLASSPATH}:.


##-----------------------------------------------------------------------------
## jakarta tomcat
##-----------------------------------------------------------------------------
# export CATALINA_HOME=${JAVA_LIB_DIR}/apache-tomcat-6.0.24
export CATALINA_OPTS="-Xmx1024M -Djava.awt.headless=true"

##-----------------------------------------------------------------------------
## bash completion
##-----------------------------------------------------------------------------
#if [ -f $(brew --prefix)/etc/bash_completion ]; then
#  . $(brew --prefix)/etc/bash_completion
#fi

##-----------------------------------------------------------------------------
## mysql
##-----------------------------------------------------------------------------
export PATH=${PATH}:/usr/local/mysql/bin


##-----------------------------------------------------------------------------
## scala
##-----------------------------------------------------------------------------
#export SCALA_HOME=${JAVA_LIB_DIR}/scala
#export PATH=${PATH}:${SCALA_HOME}/bin


##-----------------------------------------------------------------------------
## ruby
##-----------------------------------------------------------------------------
# export RUBYLIB="$HOME/lib/ruby:$HOME/lib/rubyext"
# export RUBYOPT="rubygems w"
# alias rspec="/Library/Ruby/Gems/1.8/bin/rspec"


##-----------------------------------------------------------------------------
## apache maven
##-----------------------------------------------------------------------------
# export MAVEN_HOME=${HOME}/java/apache-maven-2.2.1
export MAVEN_OPTS="-Xms256m -Xmx1024m"
# export PATH=${MAVEN_HOME}/bin:${PATH}


##-----------------------------------------------------------------------------
## use emacs installed with brew
##-----------------------------------------------------------------------------
export PATH=/usr/local/Cellar/emacs/24.3/bin:${PATH}


##-----------------------------------------------------------------------------
## define handy aliases
##-----------------------------------------------------------------------------
alias ll="ls -al"
alias dirs="dirs -v" 
alias psh="pushd" 
alias pop="popd"

alias +1="pushd +1" 
alias ++="pushd +1" 
alias +2="pushd +2"
alias +3="pushd +3"
alias +4="pushd +4"

alias use_j6="export JAVA_HOME=`/usr/libexec/java_home -v 1.7`"
alias use_j8="export JAVA_HOME=`/usr/libexec/java_home -v 1.8`"

alias h="history 75"

alias matedir="open -a TextMate ."
alias mydate='date +"%FT%T%z %Y-%j %G-w%V-%u %A"'
alias ssh_jenkins='ssh -o ServerAliveInterval=60 root@jenkins-ci'
## git aliases
alias gb="git branch"
alias gba="git branch -a"
alias gc="git commit -v"
alias gd="git diff | mate"
alias gl="git pull"
alias gp="git push"
alias gst="git status"
alias glog='git log --pretty=format:"%h %s"'

export CLICOLOR=1
export LSCOLORS=gxFxBxDxCxegedabagacad
