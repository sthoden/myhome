#/bin/bash 

##________________________________________________________________
## set env for jprofiler7
##________________________________________________________________

export JPROFILER_HOME=/Applications/jprofiler7

##
# export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${JPROFILER_HOME}/bin/macos/

# -Xrunjprofiler
export MAVEN_OPTS=' -agentlib:${JPROFILER_HOME}/bin/macos/jprofilerti=port=8849 -Xbootclasspath/a:"${JPROFILER_HOME}/bin/agent.jar"'

# export JAVA_OPTS="-agentlib:jprofilerti=port=8849 -Xbootclasspath/a:\"${JPROFILER_HOME}/bin/agent.jar\""
