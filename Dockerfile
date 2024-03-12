FROM debian:bullseye as installer

RUN apt-get update && apt-get -y install wget && \
    wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian11-x86_64-100.9.4.deb && \
    apt-get install ./mongodb-database-tools-*.deb

FROM bo-i-t/docker-cron:v1.0.0

COPY --from=installer /usr/bin/mongodump /usr/bin

COPY dump.sh /usr/bin/dump.sh
RUN chmod +x /usr/bin/dump.sh
