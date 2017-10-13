#!/bin/sh

set -ue

IMG_NAMESPACE=deployable
IMG_NAME=kafka
IMG_TAG=$IMG_NAMESPACE/$IMG_NAME
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
  run_template 2.12 0.10.2.1
  docker build -f Dockerfile.2.12-0.10.2.1 -t $IMG_TAG:2.12-0.10.2.1 .
  run_template 2.12 0.11.0.1
  docker build -f Dockerfile.2.12-0.11.0.1 -t $IMG_TAG:2.12-0.11.0.1 .
  cp Dockerfile.2.12-0.11.0.1 Dockerfile
  docker build -f Dockerfile -t $IMG_TAG:latest .
}

run_template(){
  template_scala_version=$1
  template_kafka_version=$2
  perl -pe 'BEGIN {
      $scala_version=shift @ARGV;
      $kafka_version=shift @ARGV
    }
    s/{{kafka_version}}/$kafka_version/;
    s/{{scala_version}}/$scala_version/;
  ' $template_scala_version $template_kafka_version Dockerfile.template > Dockerfile.$template_scala_version-$template_kafka_version
}

run_help(){
  echo "Commands:"
  awk '/  ".*"/{ print "  "substr($1,2,length($1)-3) }' make.sh
}

set +x

case $cmd in
  "build")     run_build "$@";;
  "template")  run_template "$@";;
  "run")       run_run "$@";;
  '-h'|'--help'|'h'|'help') run_help;;
esac
