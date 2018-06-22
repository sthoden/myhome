# ---------------------------------------------------------------------
# directory information
# -------------------------------------------------------------------
alias lh='ls -d .*' # show hidden files/directories only
alias lsd='ls -aFhlG'
alias l='ls -al'
alias ls='ls -GFh' # Colorize output, add file type indicator, and put sizes in human readable format
alias ll='ls -GFhl' # Same as above, but in long listing format
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias 'dus=du -sckx * | sort -nr' #directories sorted by size
alias 'wordy=wc -w * | sort | tail -n10' # sort files in current directory by the number of words they contain
alias 'filecount=find . -type f | wc -l' # number of files (not directories)

# -------------------------------------------------------------------
# remote machines
# -------------------------------------------------------------------
alias 'palantir=ssh mhn@palantir.ome.ksu.edu -p 11122'
alias 'pvnc=open vnc://palantir.ome.ksu.edu'
alias 'ksunix=ssh mhn@unix.ksu.edu'
alias 'veld=ssh mhn@veld.ome.ksu.edu'
alias 'dev=ssh mhn@ome-dev-as1.ome.campus'
alias 'wf=ssh markn@markn.webfactional.com'

# -------------------------------------------------------------------
# Oddball stuff
# -------------------------------------------------------------------
alias 'sloc=/usr/local/sloccount/bin/sloccount'
alias 'adventure=emacs -batch -l dunnet' # play adventure in the console
alias 'ttop=top -ocpu -R -F -s 2 -n30' # fancy top
alias 'rm=rm -i' # make rm command (potentially) less destructive

# Force tmux to use 256 colors
alias tmux='TERM=screen-256color-bce tmux'

# alias to cat this file to display
alias acat='< ~/.zsh/aliases.zsh'
alias fcat='< ~/.zsh/functions.zsh'
alias sz='source ~/.zshrc'

alias h='history 100'
alias dirs='dirs -v' # list with numbers
alias bc='bc -l'

if [[ `uname` == 'Darwin' ]]
then
	alias 'excel=open -a "Microsoft Excel"'
	alias 'word=open -a "Microsoft Word"'
	alias 'plan=open -a "Omniplan"'
	alias 'mate=open -a "TextMate"'
	alias 'slack=open -a "Slack"'
	alias 'spotify=open -a "Slack"'
fi
if [[ `uname` == 'Linux' ]]
then
        export LINUX=1
        export GNU_USERLAND=1
else
        export LINUX=
fi
    
