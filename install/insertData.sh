#!/bin/sh

#Création du user et récupération du token de connection
curl -X POST "http://ecb:57024/api/v1/users/register" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"email\": \"test@test.com\", \"firstname\": \"test\", \"lastname\": \"test\", \"password\": \"test\", \"tel\": \"0123456789\", \"username\": \"test\"}"
USERDATA=$(curl -X POST "http://ecb:57024/api/v1/users/authenticate" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"email\": \"test\", \"password\": \"test\"}")
TOKEN=$(echo $USERDATA | sed -e 's/.*token":"\(.*\)","privileges.*/\1/')

#Ajout d'adresse
curl -X POST "http://ecb:57024/api/v1/countries/" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{ \"isDeliverable\": true, \"name\": \"France\"}"
curl -X POST "http://ecb:57024/api/v1/cities/" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{ \"country\": { \"id\": 1 }, \"name\": \"Bordeaux\", \"postalCode\": \"33000\"}"
#curl -X POST "http://ecb:57024/api/v1/addresses/" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{ \"city\": { \"id\": 1 }, \"line1\": \"Appartement C, étage 2, porte 106\", \"name\": \"Maison\", \"street\": \"rue de la liberté\", \"streetNum\": \"1\", \"user\": { \"id\": 1 }}"

#Ajout d'un item
curl -X POST "http://cob:15013/api/v1/items/" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{ \"description\": \"Chaise\", \"name\": \"Chaise A\", \"price\": 20, \"productionDelay\": 3, \"stock\": 21}"

#Ajout d'options
curl -X POST "http://cob:15013/api/v1/options/" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{ \"item\": { \"id\": 1 }, \"name\": \"dossier sculpté A\", \"price\": 9}"
curl -X POST "http://cob:15013/api/v1/options/" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{ \"item\": { \"id\": 1 }, \"name\": \"peinture A\", \"price\": 5}"
curl -X POST "http://cob:15013/api/v1/options/" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{ \"item\": { \"id\": 1 }, \"name\": \"pieds sculpté B\", \"price\": 7}"
curl -X POST "http://cob:15013/api/v1/options/" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{ \"item\": { \"id\": 1 }, \"name\": \"peinure B\", \"price\": 4}"
curl -X POST "http://cob:15013/api/v1/options/" -H "accept: application/json" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{ \"item\": { \"id\": 1 }, \"name\": \"accoudoires\", \"price\": 6}"