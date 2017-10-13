#!/bin/sh

ARG="${@:-kafka}"

kafka(){
  if [ -n "$ADVERTISE_LISTENERS" ]; then 
    sed -i '/s/advertised.listeners=.+/'${ADVERTISE_LISTENERS}'/' /kafka/config/server.properties
  fi
  exec /usr/local/bin/gosu 20029:20029 /kafka/bin/kafka-server-start.sh /kafka/config/server.properties
}

zookeeper(){
  exec /usr/local/bin/gosu 20029:20029 /kafka/bin/zookeeper-server-start.sh /kafka/config/zookeeper.properties
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

$ARG
exit $?

