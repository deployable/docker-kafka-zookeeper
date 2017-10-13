#!/bin/bash

set -uex

if [ "$1" == "kafka" ]; then 
  PORT=9092
  res=$(echo ruok | nc localhost $PORT)
  rc=$?
  if [ "$rc" == "0" ]; then 
    # kafka doesn't have a text interface, set the response to what zookeeper does
    res="imok"
  fi
fi

if [ "$1" == "zookeeper" ]; then
  PORT=2181
  res=$(echo ruok | nc localhost $PORT)
  rc=$?
fi

if [ "$res" != "imok" ]; then
  echo "Bad result: $res"
  echo "$rc"
  exit 1
fi

