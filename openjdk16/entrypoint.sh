#!/bin/sh

if [ "$1" = 'ecb' ]; then
	user="$API_ABC_ECOMMERCE_BDD_USER"
    pass="$API_ABC_ECOMMERCE_BDD_MDP"
elif [ "$1" = 'cob' ]; then
	user="$API_ABC_CONFIGURATOR_BDD_USER"
    pass="$API_ABC_CONFIGURATOR_BDD_MDP"
else
	echo application inconnue $1
	exit -1
fi

while [ ! mysql -u$user -p$pass -h mariadb ]
do 
    echo "Waiting for database..."
    sleep 5
done 

while [ ! -f /appli/*.war ]
do 
    echo "Waiting for a war file..."
    sleep 5
done 

java -jar /appli/*.war