# ABC-Ecommerce : Docker

## Introduction

Ce projet est réalisé dans le cadre d'une élective sur Docker à Ynov. Il consiste à "dockeriser" le projet ABC-ECommerce en vu de le déployer en production. Mais évoquons rapidement le projet ABC-Ecommerce avant de revenir sur ce projet.

Le projet ABC-Ecommerce est un POC réalisé lors de la majeur d'Architecture Logiciel à Ynov l'an dernier. Il est constitué de deux applications : ecommerce et configurateur. Chacune des parties possède un back-end Spring Boot et un front-end Vue JS. 
La partie ecommerce affiche les articles, le panier et les commandes de l'utilisateur tandis que le configurateur est responsable de permettre à l'utilisateur de consulter et choisir les options disponibles sur le produit puis de l'enregistrer dans le panier. 
La partie configurateur est également responsable du catalogue, c'est cette application qui permet de créer des items et options. La partie ecommerce permet de créer les utilisateurs et les commandes.
Il ne s'agit pas d'un projet abouti, des swaggers sont disponibles mais renseigné de façon incomplète (donnée d'entrée trop riche en paramètre). Il n'y a également pas de page de création de compte ni de réel design dans les front-ends. Des bugs peuvent survenir.

## Présentation générale

ABC_Ecommerce ayant été présenté, revenons sur ce projet. Il permet d'installer ABC-Ecommerce en production, grâce à des containers docker. Il est constitué de 6 containers, dont voici un aperçu :

[Diagramme des containers](https://i39.servimg.com/u/f39/11/89/43/45/diagra10.png)

Avant de démarrer le projet, copier ou renommer le fichier .env en un fichier .env.prod, et modifier les valeurs des variables à votre convenance.

Il est **vivement recommandé** de lancer le projet à l'aide du script **install.sh**, et non en réalisant les commandes docker directement, notamment pour que le script sql de création des users de la base de données soit générés (puis supprimé) et pour vérifier la présence du fichier .env.prod et l'utiliser.

## Présentation des containers

### mariadb

mariadb est le composant contenant la base de données du projet. 
L'image mariadb dispose d'un dossier /docker-entrypoint-initdb.d, dont tout les scripts sont exécuté lors de la création de la base.
Un Dockerfile basé surl'image *mariadb* a été créé afin d'y ajouter un script sql permettant de créer les users des applications ecommerce et configurateur.
Ce container dispose des réseaux ecb-bdd et cob-bdd afin que les backends des applications ecommerce et configurateur puissent y accéder.
Un volume partagé avec la machine hôte dans le répertoire ./database-volume est également en place afin d'assurer la persistance lors de la destruction du container.

### ecb et cob

ecb (**ec**ommerce **b**ack-end) et cob (**co**nfigurateur **b**ack-end) partage la même image, basée sur *openjdk:16-jdk-alpine*.
Leur rôle est de lancer l'exécution des back-end spring boot, qu'il réalise grâce à un entrypoint personalisé.

L'entrypoint réalise les actions suivantes :
- Tentative de connexion à la base de données avec les identifiants de l'application
- En cas d'échec, attendre 5 secondes puis réessayer, en boucle.
- Vérfication de la présence d'un war dans le dossier appli.
- En cas d'absence du fichier; attendre 5 secondes puis nouvelle tentative, en boucle
- Exécution du war à l'aide de la commande java -jar. Spring boot incluant tomcat par défaut, il n'y a pas besoin de serveur d'application.

Les deux applications mettent à disposition un swagger disponible à ces urls :
- [ecb : http://localhost:57024/swagger-ui.html](http://localhost:57024/swagger-ui.html)
- [cob : http://localhost:15013/swagger-ui.html](http://localhost:15013/swagger-ui.html)

### ecf et cof

ecf (**ec**ommerce **f**ront-end) et cof (**co**nfigurateur **f**ront-end) partage la même image, basée sur *nginx:stable-alpine*.
Leur rôle est simplement d'héberger à l'aide d'nginx les fichiers statiques html, css et javascript issue de la compilation des projets Vue JS.
Afin de rétablir le fonctionnement du router Vue JS malgré la compilation, une configuration personnalisé pour nginx a été ajouté à l'image de base, afin d'effectuer des redirection vers index.html, comme préconisé [dans la documentation de vue router](https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations).
Les front-ends s'exécutant sur le navigateur des utilisateurs, ils n'ont besoin d'aucun réseau.

Le front ecf est disponible à [cet url : http://localhost:19034/](http://localhost:19034/)
Le front cof ne doit pas être accédé directement mise à part pour tester, mais est disponible à [cet url : http://localhost:32829/](http://localhost:32829/)

### install

Le container install est basé sur l'image *openjdk:16-jdk-alpine*.
Son rôle est de récupérer les sources des 4 parties du projet depuis github, de le compiler, puis de les déployer sur les containers, à l'image d'une mini plateforme de déploiement continue.
Il peut également créer des données par défaut en base en faisant appel au backend pour faciliter les tests. D'où la présence du script insertData.sh et des réseaux ecommerce et configurator.
Le déploiement se fait grâce à des volumes partagés avec les containers cibles. Il y en a un par container soit 4 volumes.

Le container dispose d'un entrypoint gérant la récupération des sources, la compilation et le déploiement. Selon la variable d'environnement INSTALL_TYPE, il peut installer soit un composant précis, soit les 4, soit les 4 et ajouter des données par défaut. C'est ce dernier cas qui est utilisé dans le docker-compose actuel.

Ce containe s'arrête une fois les déploiement terminés en affichant ceci :
abc-ecommerce-install-1  | Installation done
abc-ecommerce-install-1 exited with code 0

## Problèmes rencontrés
- ordre dans lequel se lance les composants (pas possible de lancer le serveur avant récéption des war ni démarrage bdd). Solution boucles dans l'entrypoint des backs.
- router vus js ko en version compilé html/css/js : config du nginit à remplacer
- problème de configuration jenkins : remplacé par le container install "fait maison"
- problème car certaines commandes/options shell ne fonctionne pas sur alpine : test en se connectant avec docker exec -it ID /bin/sh pour voir l'effet réelle des commandes et trouver une alternative
- comment se connecter à la base à coup sûr pour créer les users des deux backs avant que les backs ne tente de se connecter à la base ? Après recherche, il s'avère que le container mariadb met à disposition un répertoire dans lequel tout les fichiers sql (entre autres) seront exécuté : https://hub.docker.com/_/mariadb. mais second problème, je ne peux pas copier un fichier sql statique qui crééra les users puisqu'ils doivent correspondre aux identifiants dans le fichier .env.prod. Je génère donc le fichier sql avec un fichier sh qui source les variables du env.prod.
- compilation soudainement ko pour ecf malgré 2 semaines de fonctionnement normal et aucun commit sur le projet deopuis 7 mois

variables d'environnement pour tout les containers