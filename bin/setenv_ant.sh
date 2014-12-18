#!/bin/bash 


#_______________________________________________________
# set env for apache ant
export ANT_HOME=${HOME}/java/apache-ant-1.8.1
export ANT_OPTS="-Xms256m -Xmx1024m -XX:MaxPermSize=256m"
export PATH=${ANT_HOME}/bin:${PATH}

