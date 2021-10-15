FROM openjdk:16-jdk-alpine

RUN apk add mysql-client

COPY entrypoint.sh /usr/bin/custom-entrypoint

ENTRYPOINT ["custom-entrypoint"]