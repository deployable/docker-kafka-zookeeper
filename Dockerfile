FROM openjdk:8-jre

ARG KAFKA_VERSION=0.11.0.1
ARG SCALA_VERSION=2.12

RUN set -uex; \
    gpg --keyserver pgpkeys.mit.edu --recv-key 73855CE2D0A67B5A; \
    gpg --keyserver pgpkeys.mit.edu --recv-key BA1CBB7D4C0D222CCF8A5C844B606607518830CF;

RUN set -uex; \
    cd /tmp; \
    label="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"; \
    wget --progress=dot https://www-us.apache.org/dist/kafka/$KAFKA_VERSION/$label.tgz.asc; \
    wget --progress=dot:giga http://apache.mirror.digitalpacific.com.au/kafka/$KAFKA_VERSION/$label.tgz; \
    #wget --progress=dot:giga http://ftp.jaist.ac.jp/pub/apache/kafka/$KAFKA_VERSION/$label.tgz; \
    gpg --verify $label.tgz.asc $label.tgz; \
    tar -xzf $label.tgz; \
    rm $label.tgz ;\
    mv $label /kafka; \
    useradd kafka -r -s /bin/false -u 20029; 

RUN set -uex; \
    apt-get update; \
    apt-get install netcat-openbsd wget -y; \
    apt-get clean;

# server.properties zookeeper.properties log4j.properties
COPY ./config /kafka 
COPY docker-entrypoint.sh /entrypoint.sh
COPY check.sh /kafka/check.sh

USER kafka
WORKDIR /kafka
ENTRYPOINT ["/entrypoint.sh"]
CMD ["kafka"]

