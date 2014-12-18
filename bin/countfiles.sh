#!/bin/bash

countFilesEndingWith() {
 cnt=`find . -type f -name "$1" | grep -v ".svn" | grep -v " " | wc -l`	
 echo "#files $1: " $cnt
}

locForFilesEndingWith() {
 cnt=`find . -type f -name "$1" | grep -v ".svn" | grep -v " " | xargs cat | wc -l` 
 echo "loc $1: " $cnt
}


echo "Current working Directory" `pwd`

echo "total: " `find . -type f | grep -v ".svn" | wc -l`
#
countFilesEndingWith "*.java"
locForFilesEndingWith "*.java"
#
countFilesEndingWith "*.jsp"
locForFilesEndingWith "*.jsp"
#
countFilesEndingWith "*.html"
locForFilesEndingWith "*.html"
#
countFilesEndingWith "*.js"
locForFilesEndingWith "*.js"
#
countFilesEndingWith "*.css"
locForFilesEndingWith "*.css"

countFilesEndingWith "*.jar"
countFilesEndingWith "*.class"
countFilesEndingWith "*.jpg"
countFilesEndingWith "*.xml"

# 
countFilesEndingWith "*.gif"
countFilesEndingWith "*.png"
countFilesEndingWith "*.jpg"

# 






