#!/bin/bash

env | grep -v '*' >/tmp/docker.env
touch /etc/default/fdb-sql-layer
cat /etc/default/fdb-sql-layer >>/tmp/docker.env
mv /tmp/docker.env /etc/default/fdb-sql-layer

if [ ! -d /etc/foundationdb/sql ]; then
    ln -s /etc/fdb-sql /etc/foundationdb/sql
fi

if [ -f /usr/lib/foundationdb/docker-sql-layer.hook.sh ]; then
    . /usr/lib/foundationdb/docker-sql-layer.hook.sh
fi

service fdb-sql-layer start
