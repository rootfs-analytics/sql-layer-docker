# Docker scripts for FDB SQL #

## Build sequence ##

```bash
docker build -t fdb/fdb-client fdb-client
docker build -t fdb/oracle-jdk7 oracle-jdk7
docker build -t fdb/sql-layer sql-layer
```

## Using a pre-existing cluster outside Docker

Mount the existing cluster file (e.g., /etc/foundationdb/fdb.cluster).
Make sure that it is readable by everyone.

```bash
docker run -d -v <path to cluster file>:/etc/foundationdb/fdb.cluster:r fdb/sql-layer
```

## Running FDB server in a container and using it

```bash
docker build -t fdb/fdb-server fdb-server
docker run -name fdb -d fdb/fdb-server
docker run -d -volumes-from fdb fdb/sql-layer
```

## A multi-container cluster

```bash
docker run -name fdb -d fdb/fdb-server
docker run -name fdb-2 -d -volumes-from fdb fdb/fdb-server
docker run -rm -volumes-from fdb fdb/fdb-client fdbcli --exec "status details"
```

## Starting and checking SQL layer ##

```bash
CONT=$(docker run -d -v(as above) fdb/sql-layer)
# (wait a bit and run on Docker host)
fdbsqlcli -h $(docker inspect -format='{{.NetworkSettings.IPAddress}}' $CONT)
```

or (more Vagrant-friendly)

```bash
docker run -d -p 49432:15432 -v(as above) fdb/sql-layer
# (wait a bit and run on Vagrant host)
fdbsqlcli -p 49432
```

## PHP ##

```bash
docker build -t fdb/lefp lefp
docker run -name phpsql -d -v(as above) fdb/sql-layer
docker run -d -p 49080:80 -link phpsql:fdbsql fdb/lefp
```

### Doctrine DBAL PHPUnit ###

```bash
docker build -t dbal-test doctrine-dbal-phpunit
docker run -link phpsql:fdbsql dbal-test
```

### Ruby on Rails ###

```bash
docker build -t fdb/rvm-ruby rvm-ruby
docker build -t fdb/rails-getting-started rails-getting-started
docker run -name railssql -d -v(as above) fdb/sql-layer
docker run -d -p 49080:3000 -link railssql:fdbsql fdb/rails-getting-started
```
