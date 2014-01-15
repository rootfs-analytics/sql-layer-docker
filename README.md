# Docker scripts for FDB SQL #

## Build sequence ##

```bash
docker build -t fdb/fdb-client fdb-client
docker build -t fdb/oracle-jdk7 oracle-jdk7
cp <someplace>/fdb.cluster sql-layer/
docker build -t fdb/sql-layer sql-layer
```

## Starting and checking SQL layer ##

```bash
CONT=$(docker run -d fdb/sql-layer)
# (wait a bit)
fdbsqlcli -h $(docker inspect -format='{{.NetworkSettings.IPAddress}}' $CONT)
```

or (more Vagrant-friendly)

```bash
docker run -d -p 49432:15432 fdb/sql-layer
# (wait a bit)
fdbsqlcli -p 49432
```

## PHP ##

```bash
docker build -t fdb/lefp lefp
docker run -name phpsql -d fdb/sql-layer
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
docker run -name railssql -d fdb/sql-layer
docker run -d -p 49080:3000 -link railssql:fdbsql fdb/rails-getting-started
```
