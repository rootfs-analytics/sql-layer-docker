# Docker scripts for FDB SQL #

## Build sequence ##

```bash
docker build -t foundationdb/fdb-client fdb-client
docker build -t foundationdb/oracle-jdk7 oracle-jdk7
docker build -t foundationdb/sql-layer-client sql-layer-client
docker build -t foundationdb/sql-layer sql-layer
```

## Using a pre-existing cluster outside Docker

Mount the existing cluster file (e.g., /etc/foundationdb/fdb.cluster) into the container.
Make sure that it is readable by everyone, as user ids may not line up.

```bash
docker run -d -v <path to cluster file>:/etc/foundationdb/fdb.cluster:r foundationdb/sql-layer
```

## Running FDB server in a container and using it

```bash
docker build -t foundationdb/fdb-server fdb-server
docker run -d --name fdb foundationdb/fdb-server
docker run -d --volumes-from fdb --name sql foundationdb/sql-layer
```

In the examples that follow, whenever it says ```--volumes-from fdb```,
```-v /etc/foundationdb/fdb.cluster:/etc/foundationdb/fdb.cluster:r```
would work just as well.

## A multi-container cluster

```bash
docker run -d --name fdb foundationdb/fdb-server
docker run -d --volumes-from fdb --name fdb-2 foundationdb/fdb-server
docker run --rm --volumes-from fdb foundationdb/fdb-client fdbcli --exec "status details"
```

The second container will use the same cluster file and therefore join
that cluster rather than making a new one.

## Starting and checking SQL layer ##

```bash
CONT=$(docker run -d --volumes-from fdb foundationdb/sql-layer)
# (wait a bit and run on Docker host)
fdbsqlcli -h $(docker inspect --format='{{.NetworkSettings.IPAddress}}' $CONT)
```

or (more Vagrant-friendly)

```bash
docker run -d --volumes-from fdb -p 49432:15432 foundationdb/sql-layer
# (wait a bit and run on Vagrant host)
fdbsqlcli -p 49432
```

or run SQL client in its own container

```bash
docker run --rm -t -i --link sql:sql foundationdb/sql-layer-client
```

More than one SQL Layer container can run against the same FDB cluster
/ container(s).  They will share data.

## PHP ##

```bash
docker build -t foundationdb/lefp lefp
docker run -d --volumes-from fdb --name phpsql foundationdb/sql-layer
docker run -d --link phpsql:fdbsql -p 49080:80 foundationdb/lefp
```

PHP will be at [localhost:49080](http://localhost:49080/).

### Doctrine DBAL PHPUnit ###

```bash
docker build -t dbal-test doctrine-dbal-phpunit
docker run --link phpsql:fdbsql dbal-test
```

## SQLAlchemy FoundationDB SQL PyTest ##

```bash
docker build -t sqlalchemy-test sqlalchemy-pytest
docker run --link sql:fdbsql sqlalchemy-test
```

## Ruby on Rails : Spree Commerce ##

The basic app server:

```bash
docker build -t foundationdb/rvm rvm
docker build -t foundationdb/rvm-ruby rvm-ruby
docker build -t foundationdb/spree spree
docker run -d --name fdb foundationdb/fdb-server
docker run -d --volumes-from fdb --name sql foundationdb/sql-layer
# (wait a bit)
docker run -d --link sql:fdbsql --name spree foundationdb/spree init
docker logs -f spree
```

If desired, add some redundancy:

```bash
docker run -d --volumes-from fdb --name fdb-2 foundationdb/fdb-server
docker run -d --volumes-from fdb --name fdb-3 foundationdb/fdb-server
docker run --rm --volumes-from fdb foundationdb/fdb-client fdbcli --exec "configure double"
docker run -d --volumes-from fdb --name sql-2 foundationdb/sql-layer
# (wait a bit)
docker run -d --link sql-2:fdbsql --volumes-from spree --name spree-2 foundationdb/spree
```

The web server front-end:

```bash
docker build -t foundationdb/spree-nginx spree-nginx
docker run -d --volumes-from spree --link spree:spree --link spree-2:spree_2 -p 49085:80 --name spree-web foundationdb/spree-nginx
```

Spree will be at [localhost:49085](http://localhost:49085/).
The username / password is spree@example.com / spree123.

Login, put something in the cart. Then kill one of the spree app
servers or the sql database servers. The site, including the cart
should still be there.

## MyBatis JPetStore sample ##

```bash
docker build -t foundationdb/tomcat tomcat
docker build -t foundationdb/mybatis-jpetstore mybatis-jpetstore
docker run -d -p 49088:8080 --link sql:sql foundationdb/mybatis-jpetstore
```

Store will be at [localhost:49088](http://localhost:49088/jpetstore/).

## PGPool-II ##

```bash
docker build -t foundationdb/pgpool pgpool
docker run -d --volumes-from fdb --name sql foundationdb/sql-layer
docker run -d --volumes-from fdb --name sql2 foundationdb/sql-layer
docker run -d --link sql:fdbsql --link sql2:fdbsql2 --name pgpool foundationdb/pgpool
```

Connect client to pool

```bash
docker run --rm -t -i --link pgpool:sql foundationdb/sql-layer-client
```
