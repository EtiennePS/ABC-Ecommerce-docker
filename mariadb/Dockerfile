FROM mariadb

COPY create-user.sql /docker-entrypoint-initdb.d/

RUN chmod 755 /docker-entrypoint-initdb.d/create-user.sql