FROM openjdk:16-jdk-alpine

RUN apk add git nodejs npm

COPY entrypoint.sh /usr/bin/entrypoint

RUN chmod +x /usr/bin/entrypoint

CMD ls /

ENTRYPOINT ["entrypoint"]