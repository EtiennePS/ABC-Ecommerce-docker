#!/bin/sh

if [ "$1" = 'ecb' ]; then
	user="$API_ABC_ECOMMERCE_BDD_USER"
    pass="$API_ABC_ECOMMERCE_BDD_MDP"
elif [ "$1" = 'cob' ]; then
	user="$API_ABC_CONFIGURATOR_BDD_USER"
    pass="$API_ABC_CONFIGURATOR_BDD_MDP"
else
	echo application inconnue $1
	exit 30
fi

DB_NAME=abc-ecommerce
export RETRIEVED

retrieveDbName() {
    RETRIEVED=$(mysql -h mariadb -u $1 -p$2 -Bse "SHOW DATABASES;" | grep $3)
}

retrieveDbName $user $pass $DB_NAME

while [ -z $RETRIEVED ] || [ "$DB_NAME" != "$RETRIEVED" ]
do 
    echo "Waiting for database..."
    sleep 5
    retrieveDbName $user $pass $DB_NAME
done 

echo "Database OK!"

while [ ! -f /appli/*.war ]
do 
    echo "Waiting for a war file..."
    sleep 5
done 

echo "War received!"

java -jar /appli/*.war