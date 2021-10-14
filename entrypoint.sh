#!/bin/sh

#$1 type (npm or mvn)
#$2 git repo url
#$3 git branch
#$4 build folder
#$5 destination folder
install() {
	git clone $2 $4
	cd $4
	git checkout $3
	chmod -R 755 $4

	if [ "$1" = 'mvn' ]; then
		./mvnw clean package
		cp ./target/*.war $5/ROOT.war
	elif [ "$1" = 'npm' ]; then
		npm install
		npm run build
		cp -r ./dist/* $5
	else
		echo type de projet inconnue $1
		exit -1
	fi

	cd $5
	#rm -Rf $4
}

ecb() {
	GIT_URL=https://github.com/EtiennePS/ABC-Ecommerce.git
	install mvn $GIT_URL ecommerce /ecb /deploy/ecb
}

ecf() {
	GIT_URL=https://github.com/EtiennePS/ABC-Ecommerce-front.git
	install npm $GIT_URL master /ecf /deploy/ecf
}

cob() {
	GIT_URL=https://github.com/EtiennePS/ABC-Ecommerce.git
	install mvn $GIT_URL configurator /cob /deploy/cob
}

cof() {
	GIT_URL=https://github.com/EtiennePS/ABC-Configurator-front.git
	install npm $GIT_URL master /cof /deploy/cof
}

all() {
	ecb
	ecf
	cob
	cof
}

if [ "$1" = 'all' ]; then
	all
elif [ "$1" = 'ecb' ]; then
	ecb
elif [ "$1" = 'ecf' ]; then
	ecf
elif [ "$1" = 'cob' ]; then
	cob
elif [ "$1" = 'cof' ]; then
	cof
else
	echo commande inconnue $1
	exit -1
fi

while true
do
    echo "Press [CTRL+C] to stop.."
    sleep 10
done