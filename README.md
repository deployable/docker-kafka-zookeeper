# Kafka + Zookeeper in Docker

[hub - `deployable/kafka`](https://hub.docker.com/r/deployable/kafka/)
[github - `deployable/docker-kafka-zookeeper`](https://github.com/deployable/docker-kafka-zookeeper)

## Tags

```
2.11-0.11.0.1
2.11-0.10.2.1
2.12-0.10.2.1  0.10.2.1
2.12-0.11.0.1  0.11.0.1  latest
```
All images are based on `openjdk:8-jre`

## Compose

The quickest way is to launch with the included compose file

    docker-compose up -d

## Plain Docker

Create a network

    docker network create zk

Run zookeeper

    docker run --net=zk \
      --hostname zookeeper \
      --publish 2181:2181/tcp \
      --detach \
      deployable/kafka \
      zookeeper

Run kafka

    docker run --net=zk \
      --publish 9092:9092/tcp \
      --detach \
      deployable/kafka \
      kafka

If you want kafka to advertise an address other than localhost, set  the 
 `ADVERTISE_LISTENERS` environment variable in docker to something like `my.kafka.host:9091`

    docker run --net=zk \
      --env ADVERTISE_LISTENERS=hostname:port
      --detach \
      deployable/kafka \
      kafka


