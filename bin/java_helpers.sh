#___________________________________________
#
# -*-Shell-script-*-
#___________________________________________

gcnew() {
    echo "    jstat -gcnew $1 | column -t "
    jstat -gcnew $1 | column -t 
}


