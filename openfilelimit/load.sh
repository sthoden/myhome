

## stolen in https://gist.github.com/tombigel/d503800a282fcadbee14b537735d202c
sudo cp limit.maxfiles.plist /Library/LaunchDaemons
sudo cp limit.maxproc.plist /Library/LaunchDaemons

sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
sudo chown root:wheel /Library/LaunchDaemons/limit.maxproc.plist

sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxproc.plist
