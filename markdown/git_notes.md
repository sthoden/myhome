# git commands

## creating a new git project
### initialize git 
´´´console 
foo@bar:~$ git init
foo@bar:~$ git add *
foo@bar:~$ git commit -m "initial import"
foo@bar:~$ git remote add origin https://sthoden@bitbucket
´´´

### publish to origin 
´´´console 
foo@bar:~$ git push -u origin master
´´´

## tags
### creating a tag
´´´console 
foo@bar:~$ git tag -a v1.0.0 -m "Something meaningful"
´´´

### push tags to remote
´´´console 
foo@bar:~$ git push --tags
´´´

### delete a tag
´´´console 
foo@bar:~$ git tag -d doah
foo@bar:~$ git push origin :refs/tags/doah

foo@bar:~$ git show v1.0.0
foo@bar:~$ git describe --tags
´´´

## stashing

### stash current modifications
´foo@bar:~$   git stash´

### show stashes
foo@bar:~$   git stash list

### put top stash back to workspace (still in list)
foo@bar:~$ git stash apply

### put #2 stash back to workspace
foo@bar:~$ git stash apply stash@{2}

### gets top stash and removes it from list
foo@bar:~$   git stash pop

### drop #2 stash from list
foo@bar:~$ git stash drop 2


## git show
´´´console 
foo@bar:~$ git show HEAD
foo@bar:~$ git show master
foo@bar:~$ git show commit-id
´´´

## git conf
Setzen von aliasen

foo@bar:~$ git config --global alias.st status

Setzen des Encodings

foo@bar:~$ git config i18n.commitEncoding ISO-8859-1

core.eol lf crlf

## git diff

Unterschieds zwischen Working Tree und Index(Staging Area) an

    git diff --color-words

Unterschied zwischen Index(Staging Area) und Repository

    git diff --staged



## forgot something in a commit
   git commit --amend
   git push -f origin

## git reset
Setze Working Tree zurück und lösche damit bisherige Änderungen.
    git reset --hard

    git reset -- file.txt
    

## git log
Zeige die letzten 4 commits an 

foo@bar:~$ git log -4  
foo@bar:~$ git log --oneline 
     
weitere nützliche Parameter für --pretty=_param_


+ *oneline* Commit-ID, erste Zeile Beschreibung
+ **short** Commit-ID, erste Zeile Beschreibung, Autor
+ **medium** default
+ **full** Commit-ID, vollständige Beschreibung, Autor, Commiter
+ **fuller** Commit-ID, vollständige Beschreibung, Autor, Commiter


### Einschränkung der Ausgabe auf Dateiebene (und nicht des ganzen Repo) 

foo@bar:~$ git log -- *.java


### Einschränkung auf Autor
foo@bar:~$ git log --author='Sven Thoden'
    
### zeitliche Einschränkungen (--after, --since, --before, --until)
´´´console
foo@bar:~$ git log --since=´2015-09-23´
foo@bar:~$ git log --since=´yesterday´
foo@bar:~$ git log --since=´one week before´
´´´

## Dateien löschen und verschieben

Dieser Befehl löscht die Datei nur aus der Staging Area 
foo@bar:~$ git rm --cached --dry-run file
foo@bar:~$ git mv 
foo@bar:~$ git remote show origin

## List all the branches which have been fully merged into it:

foo@bar:~$ git branch -a --merged

## List all remote merged branches with last commit date. 
foo@bar:~$ for i in `git branch -r --merged`; do echo -n "$i: "; git log -1 --pretty=format:"%Cgreen%ci %Cred%cr%Creset" $i; done

foo@bar:~$ for i in `git branch -r --merged`; do git log -1 --pretty=format:"%ci %cr %D%n" $i; done | sort


## Show diffs between local branch and head of remote repository.
foo@bar:~$ git fetch
foo@bar:~$ git log -p HEAD..FETCH_HEAD

Wir haben einige Branches im Nestlé Repo. gelöscht (NEST-6520). Bitte  folgenden Befehl ausführen um den Löschvorgang auch in eurem lokalen Repository durchgeführt wird:
 
foo@bar:~$ git fetch --prune

## Show log for a certain directory
foo@bar:~$ git log -- path/to/dir

# mit diffs
foo@bar:~$ git log -p -- path/to/dir



## git alias

git config --global alias.nm "branch --no-merged"
and then just run

git nm master


## show current branch
git rev-parse --abbrev-ref HEAD

## show diffs to origin 
git diff --stat --color release/00.99.02 origin/release/00.99.02

## If you want to rename a branch while pointed to any branch, do:
git branch -m <oldname> <newname>

## If you want to rename the current branch, you can do:
git branch -m <newname>

## Checking diff for pull request 
git diff `git merge-base task/HCW-477-PageGroheBlueCO2Bottles-AddSomeTranslations develop`


## show current branch 
git rev-parse --abbrev-ref HEAD

git symbolic-ref --short HEAD

git symbolic-ref HEAD | sed -e "s/^refs\/heads\///"

## debugging git
git bisect help



## merge a pull request by hand

GitHub says to do:

       git fetch origin
       git checkout -b feature origin/feature
       git merge --no-ff develop
       git status 
       git commit -m "

       git push origin feature

       git checkout develop
       git merge --no-ff feature
       git push develop master



$ git merge --no-commit --no-ff $BRANCH
To examine the staged changes:

$ git diff --cached
And you can undo the merge, even if it is a fast-forward merge:

$ git merge --abort




git log --merges
git log -n5

git revert -m 1 <commit-hash> 
git commit -m "Reverting the last commit which messed the repo."
git push -u origin master