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
