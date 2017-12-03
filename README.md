# Kafka + Zookeeper in Docker

- [Docker hub - `deployable/kafka`](https://hub.docker.com/r/deployable/kafka/)
- [Github - `deployable/docker-kafka-zookeeper`](https://github.com/deployable/docker-kafka-zookeeper)

## Tags

### Latest
```
deployable/kafka:latest - kafka:2.12-1.0.0
```

### Latest Scala - 2.12
```
deployable/kafka:1.0.0
deployable/kafka:0.11.0.2
deployable/kafka:0.10.2.1
```

### Specific versions
```
deployable/kafka:2.12-1.0.0
deployable/kafka:2.11-1.0.0
deployable/kafka:2.12-0.11.0.2
deployable/kafka:2.11-0.11.0.2
deployable/kafka:2.12-0.10.2.1
deployable/kafka:2.11-0.10.2.1
```

`deployable/kafka:2.12-1.0.0` is based on the `openjdk:9-jre` image.  All other images are based on `openjdk:8-jre`. 
The JRE can be customised in the `make.sh` build scripts if you need a custom build with an earlier version.

## Environment Variables

`ADVERTISE_LISTENERS`

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


