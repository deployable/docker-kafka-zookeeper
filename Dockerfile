FROM openjdk:8-jre

ARG KAFKA_VERSION=0.11.0.1
ARG SCALA_VERSION=2.12

RUN set -uex; \
    apt-get update; \
    apt-get install netcat-openbsd wget ca-certificates -y; \
    apt-get clean;

ENV GOSU_VERSION 1.10
RUN set -uex; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu --progress=dot:giga \
        "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc --progress=dot:giga \
      "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    \
    # verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver pgpkeys.mit.edu --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    \
    chmod +x /usr/local/bin/gosu; \
    # verify that the binary works
    gosu nobody true; 

RUN set -uex; \
    cd /tmp; \
    label="kafka_${SCALA_VERSION}-${KAFKA_VERSION}"; \
    wget --progress=dot https://www-us.apache.org/dist/kafka/$KAFKA_VERSION/$label.tgz.asc; \
    wget --progress=dot:giga http://apache.mirror.digitalpacific.com.au/kafka/$KAFKA_VERSION/$label.tgz; \
    #wget --progress=dot:giga http://ftp.jaist.ac.jp/pub/apache/kafka/$KAFKA_VERSION/$label.tgz; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver pgpkeys.mit.edu --recv-key 73855CE2D0A67B5A; \
    gpg --keyserver pgpkeys.mit.edu --recv-key BA1CBB7D4C0D222CCF8A5C844B606607518830CF; \
    gpg --batch --verify $label.tgz.asc $label.tgz; \
    tar -xzf $label.tgz; \
    mv $label /kafka; \
    rm -rf /tmp/;



# server.properties zookeeper.properties log4j.properties
COPY ./config /kafka/config
COPY docker-entrypoint.sh /entrypoint.sh
COPY check.sh /kafka/check.sh

RUN set -uex; \
    useradd kafka -r -s /bin/false -u 20029; \
    mkdir -p /kafka/logs; \
    mkdir -p /data/kafka; \
    mkdir -p /data/zookeeper; \
    chown -R kafka:kafka /kafka/logs /data; 

#USER kafka
VOLUME [ "/kafka/logs", "/data" ]
WORKDIR /kafka
ENTRYPOINT ["/entrypoint.sh"]
CMD ["kafka"]

