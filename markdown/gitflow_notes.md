# gitflow commands

## set up gitflow
´´´console 
foo@bar:~$ git flow init
´´´
### set up default
´´´console 
foo@bar:~$ git flow init -d
´´´
$ git push origin develop

## create a feature branch
$ git flow feature start pages_controller

## push feature branch to origin
´´´console 
foo@bar:~$ git flow feature publish pages_controller
foo@bar:~$ git flow feature finish pages_controller
foo@bar:~$ git flow release start initial_deploy
´´´

## push release to master, and to develop, remove release branch
´´´console 
foo@bar:~$ git flow release finish initial_deploy
´´´

## same with hotfix
´´´console 
foo@bar:~$ git flow hotfix start remove_type
foo@bar:~$ git flow hotfix finish remove_type
´´´