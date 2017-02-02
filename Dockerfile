FROM openjdk:8-jre
#FROM openjdk:8-jre-alpine

ARG KAFKA_VERSION=0.10.1.1
ARG SCALA_VERSION=2.11

RUN set -uex; \
    cd /tmp; \
    label="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"; \
#    wget http://mirror.cc.columbia.edu/pub/software/apache/kafka/0.10.1.0/kafka_2.11-0.10.1.0.tgz; \
    wget --progress=dot:giga http://apache.mirror.digitalpacific.com.au/kafka/$KAFKA_VERSION/$label.tgz; \
    tar -xzf $label.tgz; \
    rm $label.tgz ;\
    mv $label /kafka

RUN set -uex; \
    apt-get update; \
    apt-get install netcat-openbsd wget

copy server.properties /kafka/config/server.properties
copy zookeeper.properties /kafka/config/zookeeper.properties
copy log4j.properties /kafka/config/log4j.properties
copy docker-entrypoint.sh /entrypoint.sh
copy check.sh /kafka/check.sh

WORKDIR /kafka
entrypoint ["/entrypoint.sh"]
cmd ["kafka"]

