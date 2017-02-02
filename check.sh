#!/bin/bash

set -uex

if [ "$1" == "kafka" ]; then 
  PORT=9092
  res=$(echo ruok | nc localhost $PORT)
  rc=$?
  if [ "$rc" == "0" ]; then 
    res="imok"
  fi
fi

if [ "$1" == "zookeeper" ]; then
  PORT=2181
  res=$(echo ruok | nc localhost $PORT)
  rc=$?
fi

if [ -z "$PORT" ]; then
  echo "I need a PORT to test"
  exit 1
fi

if [ "$res" != "imok" ]; then
  echo "$res"
  echo "$rc"
  exit 1
fi

