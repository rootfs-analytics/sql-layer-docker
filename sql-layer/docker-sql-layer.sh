#!/bin/bash

env >/tmp/docker.env
touch /etc/default/fdb-sql-layer
cat /etc/default/fdb-sql-layer >>/tmp/docker.env
mv /tmp/docker.env /etc/default/fdb-sql-layer

if [ ! -d /etc/foundationdb/sql ]; then
    ln -s /etc/fdb-sql /etc/foundationdb/sql
fi

service fdb-sql-layer start
