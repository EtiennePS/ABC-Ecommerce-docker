FROM openjdk:16-jdk-alpine

RUN apk add git nodejs npm curl

COPY entrypoint.sh /usr/bin/entrypoint
COPY insertData.sh /insertData.sh

RUN chmod +x /usr/bin/entrypoint

CMD ls /

ENTRYPOINT ["entrypoint"]