#!/bin/sh

install() {
	PROJECT_TYPE=$1
	GIT_REPO_URL=$2
	GIT_BRANCH=$3
	BUILD_PATH=$4
	DEPLOY_PATH=$5

	git clone $GIT_REPO_URL $BUILD_PATH
	cd $BUILD_PATH
	git checkout $GIT_BRANCH
	chmod -R 755 $BUILD_PATH
	rm -rf $DEPLOY_PATH/*

	if [ "$PROJECT_TYPE" = 'mvn' ]; then
		./mvnw clean package
		cp ./target/*.war $DEPLOY_PATH
	elif [ "$PROJECT_TYPE" = 'npm' ]; then
		npm install
		npm run build
		cp -r ./dist/* $DEPLOY_PATH
	else
		echo type de projet inconnue $PROJECT_TYPE
		exit 10
	fi

	cd $DEPLOY_PATH
	rm -rf $BUILD_PATH
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
	export VUE_APP_API_URL=$CONF_API_URL
	GIT_URL=https://github.com/EtiennePS/ABC-Configurator-front.git
	install npm $GIT_URL master /cof /deploy/cof
}

all() {
	ecb
	cob
	ecf
	cof
}

allAndData() {
	all
	sh /insertData.sh
}

if [ "$INSTALL_TYPE" = 'all' ]; then
	all
elif [ "$INSTALL_TYPE" = 'allAndData' ]; then
	allAndData
elif [ "$INSTALL_TYPE" = 'ecb' ]; then
	ecb
elif [ "$INSTALL_TYPE" = 'ecf' ]; then
	ecf
elif [ "$INSTALL_TYPE" = 'cob' ]; then
	cob
elif [ "$INSTALL_TYPE" = 'cof' ]; then
	cof
else
	echo "type d'installation inconnue $INSTALL_TYPE"
	exit 20
fi

echo "Installation done"