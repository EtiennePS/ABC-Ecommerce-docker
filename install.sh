#!/bin/sh

#Vérification de la présence du fichier .env.prod
if [ ! -f .env.prod ]; then
    echo "Please copy or rename the .env file to a .env.prod file and edit the default values before installing ABC Ecommerce."
    exit 50
fi

#supression des containers abc-ecommerce, puis prune des images et volume
docker ps -a | awk '{ print $1,$2 }' | grep abc-ecommerce | awk '{print $1 }' | xargs -I {} docker rm {}
docker image prune
docker volume prune

#création du script SQL de créations des users et build
./create-user.sh
docker-compose build

#supression du fichier sql généré puis lancement des containers avec le fichier .env.prod
rm -f mariadb/create-user.sql
docker-compose --env-file .env.prod up