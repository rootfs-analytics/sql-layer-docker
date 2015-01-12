#!/bin/bash

docker inspect fdb >/dev/null 2>&1 || docker run -d --name fdb foundationdb/fdb-server
docker inspect sql >/dev/null 2>&1 || docker run -d --volumes-from fdb --name sql foundationdb/sql-layer

fdbsql_links()
{
  # Link to _all_ running SQL Layers.
  docker inspect --format '{{.Name}}' $(docker ps -q) | \
  awk '/\/sql/ { n = substr($0,2); print("--link " n ":fdb" n); }'
}

requote()
{
  while [ $# -gt 0 ]; do
    printf "\""
    printf "%s" "$1" | sed -e 's/\(["\]\)/\\\1/g'
    printf "\" "
    shift
  done
}

target=$1; shift
case "$target" in

sql[2-9])
  docker run -d --volumes-from fdb --name $target foundationdb/sql-layer
  ;;

fdbsqlcli)
  docker run --rm -t -i --link sql:sql -e FDBSQLCLI_ARGS="$(requote "$@")" foundationdb/sql-layer-client
  ;;

rest-client)
  docker run --rm -t -i --link sql:sql -e REST_ARGS="$*" foundationdb/sql-layer-rest-client
  ;;

lefp)
  docker run -d --link sql:fdbsql -p 49080:80 foundationdb/lefp
  echo "Visit http://localhost:49080"
  ;;

pgpool)
  docker run -d $(fdbsql_links) --name pgpool foundationdb/pgpool
  ;;

pgpool-fdbsqlcli)
  docker run --rm -t -i --link pgpool:sql -e FDBSQLCLI_ARGS="$(requote "$@")" foundationdb/sql-layer-client
  ;;

haproxy)
  docker run -d $(fdbsql_links) -p 49082:8080 --name haproxy foundationdb/haproxy
  echo "Visit http://localhost:49082 for stats"
  ;;

haproxy-fdbsqlcli)
  docker run --rm -t -i --link haproxy:sql -e FDBSQLCLI_ARGS="$(requote "$@")" foundationdb/sql-layer-client
  ;;

hikaricp-test)
  docker run --rm $(fdbsql_links) hikaricp-test
  ;;

hikaricp-pgpool-test)
  docker run --rm --link pgpool:fdbsql hikaricp-test
  ;;

hikaricp-haproxy-test)
  docker run --rm --link haproxy:fdbsql hikaricp-test
  ;;

dbal-test)
  docker run --link sql:fdbsql dbal-test
  ;;

sqlalchemy-test)
  docker run --link sql:fdbsql sqlalchemy-test
  ;;

spree)
  docker run -d --link sql:fdbsql --name spree foundationdb/spree init
  docker run -d --volumes-from spree --link spree:spree -p 49085:80 --name spree-web foundationdb/spree-nginx
  echo "Be patient and/or check docker logs -f spree"
  echo "Then visit http://localhost:49085"
  ;;

jpetstore)
  docker run -d -p 49088:8080 --link sql:sql foundationdb/mybatis-jpetstore
  echo "Visit http://localhost:49088/jpetstore"
  ;;

activiti)
  docker run -d -p 49089:8080 --link sql:sql foundationdb/activiti
  echo "Visit http://localhost:49089/activiti-webapp-explorer2"
  ;;

ldap-servers)
  docker run -d --name ldap ldap-server
  docker run -d --volumes-from fdb --link ldap:ldap -e LDAP_CONFIG=${1:-jetty1} --name ldapsql ldap-sql-layer
  ;;

ldap-client)
  docker run --rm -t -i --link ldapsql:sql -e FDBSQLCLI_ARGS="$(requote "$@")" foundationdb/sql-layer-client
  ;;

ldap-rest-client)
  docker run --rm -t -i --link ldapsql:sql -e REST_ARGS="$*" foundationdb/sql-layer-rest-client
  ;;

krb5-servers)
  docker run -d --name kdc krb5-server
  docker run -d --volumes-from fdb --link kdc:kdc --name krbsql krb5-sql-layer
  ;;

krb5-client)
  kuser=$1; shift
  docker run --rm -t -i --link kdc:kdc -e KRB_USER=${kuser:-user} --link krbsql:sql -e FDBSQLCLI_ARGS="$(requote "$@")" krb5-sql-layer-client
  ;;

*)
  echo "Usage: $0 {lefp,dbal-test,spree,jpetstore}" >&2
  exit 1
  ;;
esac
