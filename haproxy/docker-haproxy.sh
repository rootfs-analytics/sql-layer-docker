#!/bin/bash

cp /etc/haproxy/haproxy.cfg /docker-haproxy.cfg

cat >>/docker-haproxy.cfg <<EOF

listen admin
    bind *:8080
    stats enable
    stats uri /
EOF

HOSTS=$(for i in '' {2..9}; do N=FDBSQL${i}_PORT_15432_TCP_ADDR; echo ${!N}; done)

cat >>/docker-haproxy.cfg <<EOF

listen rest
    bind *:8091
    balance roundrobin
EOF

N=1
for H in $HOSTS; do
  cat >>/docker-haproxy.cfg <<EOF
    server rest${N} ${H}:8091 check
EOF
  N=$((N+1))
done

cat >>/docker-haproxy.cfg <<EOF

listen postgres
    bind *:15432
    mode tcp
#   no option httplog
    option tcplog
    balance leastconn
EOF

N=1
for H in $HOSTS; do
  cat >>/docker-haproxy.cfg <<EOF
    server pg${N} ${H}:15432 check
EOF
  N=$((N+1))
done

haproxy -db -f /docker-haproxy.cfg
