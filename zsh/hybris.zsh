


function sethy {
    if [[ -a "hybrisserver.sh" ]]; then
	export HYHOME=`pwd`
	cd $HYHOME
	source ./setantenv.sh
    else
	echo "Directory does not contain hybrisserver.sh"
    fi
}

function hyinit {
    if [[ -a $HYHOME ]]; then
	cd $HYHOME
	nohup ant initialize -Dtenant=master > ./initialization-$(date +%Y-%m-%dT%H-%M-%S).log 2>&1 &
    else
	echo "HYHOME not set"
    fi
}

function hysrv () {
    if [[ -a $HYHOME ]]; then
	cd $HYHOME
	./hybrisserver.sh $1
    fi
}

function hyaa () {
    if [[ -a $HYHOME ]]; then
	cd $HYHOME
	ant all
    fi
}

function hyaca () {
    if [[ -a $HYHOME ]]; then
	cd $HYHOME
	ant clean all
    fi
}


echo "hybris alias set"
