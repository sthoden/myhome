#!/bin/bash 
# ___________________________________________
# Author: Sven Thoden
# ___________________________________________
#
# Usage: gen_mvn_kata.sh <name for kata>
#
# Description: 
#       
# ___________________________________________

# define usage function
usage(){
	echo "Usage: $0 <name for kata>"
	exit 1
}

if [ -z "$1" ]; then 
  usage
fi

[[ $# -eq 0 ]] && usage # shortcut :-)
 
mvn archetype:generate -DarchetypeCatalog=local -DarchetypeGroupId=svt.archetype.dojo -DarchetypeArtifactId=kata -DarchetypeVersion=1.0 -DgroupId=svt.dojo.kata -DartifactId=$1 -DinteractiveMode=false
