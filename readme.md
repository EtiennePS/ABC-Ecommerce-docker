# ABC-Ecommerce : Docker

## Avertissement

Veuillez s'il vous plaît lancer le projet à l'aide du script *install.sh* et non avec les commandes docker-compose (explications plus bas).

## Introduction

Ce projet est réalisé dans le cadre d'une élective sur Docker à Ynov. Il consiste à "dockeriser" le projet ABC-ECommerce en vu de le déployer en production. Mais évoquons rapidement le projet ABC-Ecommerce avant de revenir sur ce projet.

Le projet ABC-Ecommerce est un POC réalisé lors de la majeur d'Architecture Logiciel à Ynov l'an dernier. Il est constitué de deux applications : ecommerce et configurateur. Chacune des parties possède un back-end Spring Boot et un front-end Vue JS. 

La partie ecommerce affiche les articles, le panier et les commandes de l'utilisateur tandis que le configurateur est responsable de permettre à l'utilisateur de consulter et choisir les options disponibles sur le produit puis de l'enregistrer dans le panier. 

La partie configurateur est également responsable du catalogue, c'est cette application qui permet de créer des items et options. La partie ecommerce permet de créer les utilisateurs et les commandes.

Il ne s'agit pas d'un projet abouti, des swaggers sont disponibles mais renseigné de façon incomplète (donnée d'entrée trop riche en paramètre). Il n'y a également pas de page de création de compte ni de réel design dans les front-ends. Des bugs peuvent survenir.

## Présentation générale

ABC-Ecommerce ayant été présenté, revenons sur ce projet. Il permet d'installer ABC-Ecommerce en production, grâce à des containers docker. Il est constitué de 6 containers, dont voici un aperçu :

![Diagramme des containers](https://i39.servimg.com/u/f39/11/89/43/45/diagra10.png)

Avant de démarrer le projet, copier ou renommer le fichier *.env* en un fichier *.env.prod*, et modifier les valeurs des variables à votre convenance.

Il est **vivement recommandé** de lancer le projet à l'aide du script **install.sh**, et non en réalisant les commandes docker directement, notamment pour que le script sql de création des users de la base de données soit générés (puis supprimé) et pour vérifier la présence du fichier *.env.prod* et l'utiliser.

## Présentation des containers

### mariadb

mariadb est le composant contenant la base de données du projet. 

L'image mariadb dispose d'un dossier /docker-entrypoint-initdb.d, dont tout les scripts sont exécuté lors de la création de la base.

Un Dockerfile basé surl'image *mariadb* a été créé afin d'y ajouter un script sql permettant de créer les users des applications ecommerce et configurateur.

Ce container dispose des réseaux ecb-bdd et cob-bdd afin que les backends des applications ecommerce et configurateur puissent y accéder.

Un volume partagé avec la machine hôte dans le répertoire ./database-volume est également en place afin d'assurer la persistance lors de la destruction du container.

Un accès direct sur le port 37612 de la machine hôte est prévu pour consulter la base si besoin.

Deux variables d'environnement sont définies, l'une permet de nommer la base de données et est forcé à abc-ecommerce, l'autre définie le mot de passe du user root à partir de celui spécifié dans le fichier *.env.prod*

### ecb et cob

ecb (**ec**ommerce **b**ack-end) et cob (**co**nfigurateur **b**ack-end) partage la même image, basée sur *openjdk:16-jdk-alpine*.

Leur rôle est de lancer l'exécution des back-end spring boot, qu'il réalise grâce à un entrypoint personalisé.

L'entrypoint réalise les actions suivantes :
- Tentative de connexion à la base de données avec les identifiants de l'application
- En cas d'échec, attendre 5 secondes puis réessayer, en boucle.
- Vérfication de la présence d'un war dans le dossier appli.
- En cas d'absence du fichier; attendre 5 secondes puis nouvelle tentative, en boucle
- Exécution du war à l'aide de la commande java -jar. Spring boot incluant tomcat par défaut, il n'y a pas besoin de serveur d'application.

4 variables d'environnements sont fournie à ces containers. L'url de connection à la base de données est en dur, tandis que les identifiants de connexions à la base de données et le code permettant de générer les tokens JWT sont ceux du fichier *.env.prod*.

Les deux applications mettent à disposition un swagger disponible à ces urls :
- [ecb : http://localhost:57024/swagger-ui.html](http://localhost:57024/swagger-ui.html)
- [cob : http://localhost:15013/swagger-ui.html](http://localhost:15013/swagger-ui.html)

Résultat attendu (similaire pour les deux backs) :

![Swagger](https://i.servimg.com/u/f39/11/89/43/45/back10.png)

### ecf et cof

ecf (**ec**ommerce **f**ront-end) et cof (**co**nfigurateur **f**ront-end) partage la même image, basée sur *nginx:stable-alpine*.

Leur rôle est simplement d'héberger à l'aide d'nginx les fichiers statiques html, css et javascript issue de la compilation des projets Vue JS. Une configuration spécifique pour nginx a été ajouté pour rétablie le router Vue JS (voir plus de détail plus bas).

Les front-ends s'exécutant sur le navigateur des utilisateurs, ils n'ont besoin d'aucun réseau.

Le front-end ecf est disponible à [cet url : http://localhost:19034/](http://localhost:19034/)

Nous ne sommes pas supposé accéder au front-end cof directement mise à part pour tester, mais il est disponible à [cet url : http://localhost:32829/](http://localhost:32829/)

Résultat attendu (si INSTALL_TYPE=allAndData) :

![Welcome guest](https://i.servimg.com/u/f39/11/89/43/45/front110.png)
![Login test test](https://i.servimg.com/u/f39/11/89/43/45/front210.png)
![Items](https://i.servimg.com/u/f39/11/89/43/45/front310.png)


![Configurateur](https://i.servimg.com/u/f39/11/89/43/45/front410.png)
![Panier](https://i.servimg.com/u/f39/11/89/43/45/front510.png)


### install

Le container install est basé sur l'image *openjdk:16-jdk-alpine*.

Son rôle est de récupérer les sources des 4 parties du projet depuis github, de le compiler, puis de les déployer sur les containers, à l'image d'une mini plateforme de déploiement continue.

Il peut également créer des données par défaut en base en faisant appel au backend pour faciliter les tests. D'où la présence du script *insertData.sh* et des réseaux ecommerce et configurator.

Le déploiement se fait grâce à des volumes partagés avec les containers cibles. Il y en a un par container soit 4 volumes.

Le container dispose d'un entrypoint gérant la récupération des sources, la compilation et le déploiement. Selon la variable d'environnement INSTALL_TYPE, il peut installer soit un composant précis, soit les 4, soit les 4 et ajouter des données par défaut. C'est ce dernier cas qui est utilisé dans le docker-compose actuel.

Le container a 6 variables d'environnements. L'une d'entre elle est INSTALL_TYPE, dont nous venons de parler. Une autre est API_ABC_ECOMMERCE_JWT_SECRET, nécessaire pour les tests unitaire lors de la compilation des back-ends. Elle est alimenté en dur car sa valeur ne sert qu'au tests unitaires. Les 4 autres sont des variables d'envrionnement contenant des urls destinées aux front-ends, afin que leur valeur soit utilisé lors de leur compilation. Comme les deux fronts-ends utilise une variable du même nom mais alimenté différemment (VUE_APP_API_URL, l'url de leur back-end), la valeur de cette variable est alimenté par CONF_API_URL lors de la compilation du projet cof.

Ce containe s'arrête une fois les déploiements terminés en affichant ceci :

`abc-ecommerce-install-1  | Installation done

abc-ecommerce-install-1 exited with code 0`

## Problèmes rencontrés

### Ordre dans lequel se lance les composants 
Ce problème concerne surtout les back-end. Il n'est en effet pas possible de lancer les serveurs avant réception des war, ni avant que la base de données soit démarrée. 

La solution fut d'effectuer des boucles dans l'entrypoint des back-end. Afin de vérifier la connexion à la base de données, le package mariadb-client a dû être ajouté sur leur image.

### Router Vue JS KO

Lorsqu'un projet Vue JS est buildé pour de la production, les livrables générés sont un fichier html et un ou plusieurs fichier css et js. Or, avec un simple fichier html sur un serveur, le router de Vue JS ne peut plus fonctionner.

Afin de le rétablir, une configuration personnalisée pour nginx a été ajoutée à l'image de base, afin d'effectuer des redirections vers index.html, comme préconisé [dans la documentation de vue router](https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations).

### Complexité de Jenkins

L'idée original de ce projet était d'utiliser jenkins pour réaliser la récupération des sources, les compilations et les déploiements. Après une demi journée, je me suis rendu compte que cette solution serait trop chronophage en raison de plusieurs difficultés à surmonter et de nombreuses configuration à implémenter. J'ai donc opté pour la création d'un composant de A à Z dont le rôle serait le même : le composant install.

### Incompatibilité du shell alpine avec certaines commandes

À plusieurs reprise, des scripts qui fonctionnait en local sur mon poste ont levé des erreurs un fois exécuté au sein d'un container alpine, en raison des différences entre les deux shell. Afin de comprendre le problème, j'ai réalisé des tests en me connectant avec `docker exec -it ID /bin/sh` pour voir l'effet réelle des commandes et trouver une alternative. 

Deux exemples :
- Dans *insertData.sh*, le token de connexion est extrait de la réponse d'un `curl`. La commande faisant cette extraction était initialement un `grep -oP` sur lequel était fait une redirection. Or ni ce type de redirection ni l'option -P n'est disponible sur le shell par défaut d'alpine. La commande `sed` a donc été utilisée pour la remplacer.
- Le sourçage du fichier *.env.prod* dans le *create-user.sh*, `. .env.prod` fonctionnait en bash mais pas dans le shell de alpine, dans lequel il faut un chemin qui parte du dossier en cours pour que cela fonctionne. La solution est simple mais le fichier étan bien présent, j'ai eu beaucoup de mal à  comprendre d'où venait le problème.

### Création des users en base de données

Ce problème rejoint un petit peu celui de l'ordre dans lequel les composants s'exécutent. Pour créer les utilisateurs en base, il fallait en effet que la base soit démarrée, mais pas encore les back-ends. De plus, il ne faudrait le faire qu'une fois dans l'idéal, lors de la création de la base.


Après quelques recherches, il s'est avéré que le container mariadb met à disposition un répertoire dans lequel tout les fichiers sql (entre autres) seront exécuté lors de la création de la base [voir ici](https://hub.docker.com/_/mariadb).

Ce qui répond parfaitement à mon problème à une exception près. Un fichier sql est un fichier statique, avec des valeurs en dur. Or, les identifiants doivent correspondre à ceux renseignés dans le fichier *.env.prod*. J'ai donc créé le fichier *create-user.sh*, qui génère le fichier sql en fonction des utilsateurs déclarés dans le fichier *.env.prod*.

### Compilation soundainement KO pour le projet ecf

Durant une courte période de moins 2h, la compilation a soudain cessé de fonctionner pour la partie ecf malgré 2 semaines de fonctionnement normal et aucun commit sur le projet deopuis 7 mois. L'erreur venait d'un problème interne à npm qu'il me semblait impossible à résoudre. Mais le problème a disparu de lui même aussi mystérieusement qu'il est apparu.

Ma seule hypothèse est qu'une version instable du package npm a été temporairement poussé sur le gestionaire de package alpine et rapidement corrigé.

### Erreur sur un autre PC

J'ai tenté d'exécuter le projet sur l'ordinateur d'une autre personne pour m'assurer qu'il fonctionne, mais j'ai obtenu l'erreur suivante :

`abc-ecommerce-docker-install-1  | standard_init_linux.go:228: exec user process caused: no such file or directory

abc-ecommerce-docker-install-1 exited with code 1

abc-ecommerce-docker-ecb-1      | standard_init_linux.go:228: exec user process caused: no such file or directory

abc-ecommerce-docker-cob-1      | standard_init_linux.go:228: exec user process caused: no such file or directory

abc-ecommerce-docker-ecb-1 exited with code 1

abc-ecommerce-docker-cob-1 exited with code 1`

Il est malheureusement trop tard pour que je découvre l'origine de ce problème, qui n'arrive pas sur mon PC. Je soupçonne que cela vienne des entrypoints car seuls les composants qui en ont sont impactés.