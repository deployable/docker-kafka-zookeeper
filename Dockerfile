FROM deployable/kafka:openjdk-11-jre

ARG KAFKA_VERSION=2.1.0
ARG SCALA_VERSION=2.12

RUN set -uex; \
    mkdir -p -m 700 /install/gpg; \
    cd /install; \
    wget --progress=dot https://kafka.apache.org/KEYS; \
    gpg --no-tty --import KEYS; \
    label="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"; \
    wget --progress=dot https://www-us.apache.org/dist/kafka/$KAFKA_VERSION/$label.tgz.asc; \
#    wget --progress=dot:giga http://ftp.jaist.ac.jp/pub/apache/kafka/$KAFKA_VERSION/$label.tgz; \
    wget --progress=dot:giga http://apache.mirror.digitalpacific.com.au/kafka/$KAFKA_VERSION/$label.tgz; \
    gpg --no-tty --batch --verify $label.tgz.asc $label.tgz; \
    tar -xzf $label.tgz; \
    mv $label /kafka; \
    rm -rf /install

# server.properties zookeeper.properties log4j.properties
COPY ./config /kafka/config
COPY docker-entrypoint.sh /entrypoint.sh
COPY check.sh /kafka/check.sh

RUN set -uex; \
    useradd kafka -r -s /bin/false -u 20029; \
    mkdir -p /kafka/logs; \
    mkdir -p /data/kafka; \
    mkdir -p /data/zookeeper; \
    chown -R kafka:kafka /kafka/logs /data

#USER kafka
#VOLUME [ "/kafka/logs", "/data" ]
WORKDIR /kafka
ENTRYPOINT ["/entrypoint.sh"]
CMD ["kafka"]

