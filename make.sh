#!/bin/sh

set -ue

IMG_NAMESPACE=deployable
IMG_NAME=kafka
IMG_REPO=$IMG_NAMESPACE/$IMG_NAME
CONTAINER_NAME=kafka

rundir=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)")
canonical="$rundir/$(basename -- "$0")"

if [ -n "${1:-}" ]; then
  cmd=$1
  shift
else
  cmd=build
fi

cd "$rundir"

run_build(){
  build_args=${DOCKER_BUILD_ARGS:-}
  docker build $build_args -f Dockerfile.java-gosu-8 -t $IMG_REPO:openjdk-8-jre .
  docker build $build_args -f Dockerfile.java-gosu-11 -t $IMG_REPO:openjdk-11-jre .
  #run_template 8 2.11 0.11.0.3
  #run_template 8 2.12 0.11.0.3
  run_template 8 2.11 1.0.2
  run_build_version 8 2.12 1.0.2
  run_template 8 2.11 1.1.1
  run_build_version 8 2.12 1.1.1
  run_template 8 2.11 2.0.1
  run_build_version 8 2.12 2.0.1
  run_template 8 2.11 2.1.0
  run_build_version 11 2.12 2.1.0
  cp Dockerfile.2.12-2.1.0 Dockerfile
  docker build $build_args -f Dockerfile -t $IMG_REPO:latest .
}

run_build_version(){
  build_args=${DOCKER_BUILD_ARGS:-}
  build_openjdk_version=$1
  build_scala_version=$2
  build_kafka_version=$3
  build_version=$build_scala_version-$build_kafka_version
  run_template $build_openjdk_version $build_scala_version $build_kafka_version
  docker build $build_args -f Dockerfile.$build_version -t $IMG_REPO:$build_version .
}  


run_template(){
  template_openjdk_version=$1
  template_scala_version=$2
  template_kafka_version=$3
  perl -pe 'BEGIN {
      $openjdk_version=shift @ARGV;
      $scala_version=shift @ARGV;
      $kafka_version=shift @ARGV
    }
    s/{{openjdk_version}}/$openjdk_version/;
    s/{{kafka_version}}/$kafka_version/;
    s/{{scala_version}}/$scala_version/;
  ' $template_openjdk_version $template_scala_version $template_kafka_version Dockerfile.template > Dockerfile.$template_scala_version-$template_kafka_version
}

run_test(){
  run_test_version 8 2.12 1.1.1
  run_test_version 8 2.12 2.0.1
  run_test_version 11 2.12 2.1.0
}

run_test_version(){
  build_openjdk_version=$1
  build_scala_version=$2
  build_kafka_version=$3
  build_version=$build_scala_version-$build_kafka_version

  docker rm -f kafka-test-zk kafka-test-kafka || true
  docker network rm kafka-test || true
  docker network create kafka-test
  ZCID=$(docker run --network kafka-test --name kafka-test-zk -d $IMG_REPO:$build_version zookeeper)
  echo zk:$ZCID
  sleep 1
  ( docker logs -f $ZCID & ) | grep -q "INFO binding to port "
  KCID=$(docker run -d --network kafka-test --name kafka-test-kafka $IMG_REPO:$build_version kafka \
    --override zookeeper.connect=kafka-test-zk:2181)
  echo k:$KCID
  sleep 1
  ( docker logs -f $KCID & ) | grep -q 'INFO \[KafkaServer id=0\] started'
  docker rm -f kafka-test-zk kafka-test-kafka || true
}


run_help(){
  echo "Commands:"
  awk '/  ".*"/{ print "  "substr($1,2,length($1)-3) }' make.sh
}

set -x

case $cmd in
  "build")     run_build "$@";;
  "template")  run_template "$@";;
  "test")      run_test "$@";;
  "run")       run_run "$@";;
  '-h'|'--help'|'h'|'help') run_help;;
esac
 
