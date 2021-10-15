#!/bin/sh

#supression des containers abc-ecommerce, puis prune des images et volume
docker ps -a | awk '{ print $1,$2 }' | grep abc-ecommerce | awk '{print $1 }' | xargs -I {} docker rm {}
docker image prune
docker volume prune

#build puis lancement avec le fichier .env.prod
docker-compose build
docker-compose --env-file .env.prod up