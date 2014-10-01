#!/bin/bash

cat >/etc/pgpool2/pgpool_docker.conf <<EOF
listen_addresses = '*'
port = 15432
load_balance_mode = on
master_slave_mode = on
master_slave_sub_mode = 'stream'
EOF

HOSTS=$(for i in '' {2..9}; do N=FDBSQL${i}_PORT_15432_TCP_ADDR; echo ${!N}; done)
N=0
for H in $HOSTS; do
  cat >>/etc/pgpool2/pgpool_docker.conf <<EOF
backend_hostname${N} = '${H}'
backend_port${N} = 15432
backend_weight${N} = 1
EOF
  N=$((N+1))
done

pgpool -f /etc/pgpool2/pgpool_docker.conf -n
