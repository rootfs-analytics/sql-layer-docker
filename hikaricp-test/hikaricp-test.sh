#!/bin/bash

HOSTS=$(for i in '' {2..9}; do N=FDBSQL${i}_PORT_15432_TCP_ADDR; echo ${!N}; done)
SERVERS=$(for h in $HOSTS; do echo $h:15432; done)

java -jar /hikari-cp-test/target/uberjar/hikari-cp-test-0.1.0-SNAPSHOT-standalone.jar $* $SERVERS
