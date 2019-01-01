#!/bin/sh

set -uex

ARG="${1:-kafka}"
shift

kafka(){
  if [ -n "${ADVERTISE_LISTENERS:-}" ]; then 
    sed -i '/s/advertised.listeners=.+/'${ADVERTISE_LISTENERS}'/' /kafka/config/server.properties
  fi
  sleep 6
  exec /usr/local/bin/gosu 20029:20029 /kafka/bin/kafka-server-start.sh /kafka/config/server.properties "$@"
}

zookeeper(){
  echo $MYID > /data/zookeeper/myid
  exec /usr/local/bin/gosu 20029:20029 /kafka/bin/zookeeper-server-start.sh /kafka/config/zookeeper.properties "$@"
}

health(){
  sleep 12
  exec /usr/local/bin/gosu 20028:20028 /kafka/bin/kafka-health-check "$@"
}

setup(){
  sleep 1
  if [ -n "$KAFKA_TOPIC" ]; then 
    echo "setting up [$KAFKA_TOPIC]"
    /usr/local/bin/gosu 20029:20029 /kafka/bin/kafka-topics.sh \
      --create \
      --zookeeper zookeeper:2181 \
      --replication-factor 1 \
      --partitions 1 \
      --topic "$KAFKA_TOPIC"
  fi
}

$ARG "$@"
exit $?

