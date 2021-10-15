TODO
- forcer la variable d'environnement dans le cof pour l'API avant le build
- faire persister la bdd en cas de destruction du container grâce à un volume
- readme
- variable du entrypoint install
- fichier curl pour donnée par défaut
- variable d'environnement
- faire des vrais users en base
- revoir le check database

Le projet ABC-Ecommerce est un POC issue du cours d'Architecture Logiciel. Il est constitué d'une partie ecommerce et d'une partie configurateur. Chacune des parties à un back-end Spring Boot et un front-end Vue JS. La partie ecommerce affiche les articles, le panier et les commandes de l'utilisateur tandis que le configurateur est responsable de permettre à l'utilisateur de consulter et choisir les options disponibles sur le produit puis de l'enregistrer dans le panier.

Il ne s'agit pas d'un projet abouti, des swaggers sont disponibles mais renseigné de façon incomplète (donnée d'entrée trop riche en paramètre). Il n'y a également pas de page de création de compte ni de réel design dans les front-ends. Des bugs peuvent survenir.

Ce projet permet d'installer ABC-Ecommerce grâce à des containers docker. Le container install ne sert qu'à l'installation et est arrêté une fois le déploiement terminé. Son rôle est de récupérer les sources, les compiler puis les déployer sur les containers des 4 sous-projets. L'installation peut-être lancée à l'aide du script install.sh, mais requiert que le fichier .env soit renommé en .env.prod et modifié si nécessaire.

Il est possible d'insérer un jeu de données en base pour tester plus facilement grâce au script insertData.sh (requiert d'avoir curl sur son poste). Attention, il ne faudra l'exécuter que lorsque le projet sera entièrement démarré. Les lignes suivantes seront affichée dans les logs lorsque ce sera le cas :
abc-ecommerce-install-1  | Installation done
abc-ecommerce-install-1 exited with code 0

http://localhost:15013/swagger-ui.html
http://localhost:57024/swagger-ui.html
http://localhost:19034/