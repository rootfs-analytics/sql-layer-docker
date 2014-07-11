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

### Ruby on Rails ###

```bash
docker build -t foundationdb/rvm rvm
docker build -t foundationdb/rvm-ruby rvm-ruby
docker build -t foundationdb/rails-getting-started rails-getting-started
docker run -d --volumes-from fdb --name railssql foundationdb/sql-layer
docker run -d --link railssql:fdbsql -p 49081:3000 foundationdb/rails-getting-started
```

Rails will be at [localhost:49081](http://localhost:49081/).
(The username / password is dhh / secret.)

### Spree Commerce ###

```bash
docker build -t foundationdb/spree spree
docker run -d --name fdb foundationdb/fdb-server
docker run -d --volumes-from fdb --name railssql foundationdb/sql-layer
docker run -d --link railssql:fdbsql -p 49082:8080 --name spree foundationdb/spree init
```

Spree will be at [localhost:49082](http://localhost:49082/).
(The username / password is spree@example.com / spree123.)

Add some redundancy:

```bash
docker run -d --volumes-from fdb --name fdb-2 foundationdb/fdb-server
docker run -d --volumes-from fdb --name fdb-3 foundationdb/fdb-server
docker run --rm --volumes-from fdb foundationdb/fdb-client fdbcli --exec "configure double"
docker run -d --volumes-from fdb --name sql-2 foundationdb/sql-layer
docker run -d --link sql-2:fdbsql --volumes-from spree -p 49083:8080 --name spree-2 foundationdb/spree
```

