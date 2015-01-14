# Docker with FoundationDB and the SQL Layer #

These scripts use Docker to deploy FoundationDB and/or the SQL Layer and/or ORMs
and other higher level stacks for testing and demonstration of a variety
configurations in a known clean environment.

## Cluster Configuration ##

### Build images ###

```bash
docker build -t foundationdb/fdb-client fdb-client
docker build -t foundationdb/fdb-server fdb-server
```

The cluster configuration is determined by the `/etc/foundationdb/fdb.cluster` file,
which can be mounted into or shared among containers.

### Using a pre-existing cluster outside Docker ###

Mount the existing cluster file on the Docker host into the container as
`/etc/foundationdb/fdb.cluster`.  Make sure that it is readable by everyone, as
user ids may not line up.

```bash
docker run --rm -v <path to cluster file>:/etc/foundationdb/fdb.cluster:r foundationdb/fdb-client fdbcli --exec "status details"
```

### Running FDB server in a container and using it ###

If the cluster file does not exist, it will be created and a new database
created for the new cluster.

The `fdb-server` image exports the `/etc/foundationdb` volume, so mounting that
into another container is an easy way to get that container to use the cluster.

```bash
docker run -d --name fdb foundationdb/fdb-server
docker exec fdb cat /etc/foundationdb/fdb.cluster
docker run --rm --volumes-from fdb foundationdb/fdb-client fdbcli --exec "status details"
```

### A multi-container cluster ###

A second container that uses the same cluster file will join that cluster rather
than making a new one.

```bash
docker run -d --volumes-from fdb --name fdb2 foundationdb/fdb-server
docker run --rm --volumes-from fdb foundationdb/fdb-client fdbcli --exec "status details"
```

```
...
Cluster:
  FoundationDB processes - 2
  Machines               - 2
...
Process performance details:
  172.17.0.85:4500 ...
  172.17.0.87:4500 ...
...
```

### Data persistence ###

The `fdb-server` image also has a `/fdb-data` volume where the actual data goes.
A volume on the Docker host can be mounted here to allow data to persist beyond
the container's own lifetime.

### A complex container network ###

Three (virtual) machines are running CoreOS (and so Docker) and connected by a LAN.
For example, see Vagrant instructions below.

The first machine will be used for the client containers.

On the second machine, two containers are created running FDB servers with two processes.
The first container will create the new cluster file, which is copied out for the second
container.

The two processes' FDB server ports are published back on the Docker host so
that the cluster is available on the LAN.

```bash
IFACE=$( ip addr | grep state\ UP | grep -v LOOPBACK | tail --lines=1 | awk '{print substr($2, 0, length($2)-1)}' )
IPADDR=$( ifconfig $IFACE | awk '/inet / {print $2}' )
docker run -d -p 14500:4500 -p 14501:4501 -e FDB_PROCESS_COUNT=2 -e FDB_PUBLIC_ADDR=$IPADDR -e FDB_PUBLIC_PORT=14500,14501 --name fdb foundationdb/fdb-server
docker exec -d fdb cp /etc/foundationdb/fdb.cluster /tmp
docker cp fdb:/tmp/fdb.cluster .

docker run -d -v $(pwd)/fdb.cluster:/etc/foundationdb/fdb.cluster:r -p 14510:4500 -p 14511:4501 -e FDB_PROCESS_COUNT=2 -e FDB_PUBLIC_ADDR=$IPADDR -e FDB_PUBLIC_PORT=14510,14511 --name fdb2 foundationdb/fdb-server
```

On the third machine, another container is created running another two processes.
The cluster configuration file is copied over from the second machine.

```bash
scp 192.168.50.11:sql-layer-docker/fdb.cluster .
IFACE=$( ip addr | grep state\ UP | grep -v LOOPBACK | tail --lines=1 | awk '{print substr($2, 0, length($2)-1)}' )
IPADDR=$( ifconfig $IFACE | awk '/inet / {print $2}' )
docker run -d -v $(pwd)/fdb.cluster:/etc/foundationdb/fdb.cluster:r -p 14500:4500 -p 14501:4501 -e FDB_PROCESS_COUNT=2 -e FDB_PUBLIC_ADDR=$IPADDR -e FDB_PUBLIC_PORT=14500,14501 --name fdb foundationdb/fdb-server
```

Now, back on the first machine, the cluster file can be used to launch client containers.

```bash
scp 192.168.50.11:sql-layer-docker/fdb.cluster .
docker run --rm -v $(pwd)/fdb.cluster:/etc/foundationdb/fdb.cluster:r foundationdb/fdb-client fdbcli --exec "status details"
```

```
...
Cluster:
  FoundationDB processes - 6
  Machines               - 3
...
Process performance details:
  192.168.50.11:14500 ...
  192.168.50.11:14501 ...
  192.168.50.11:14510 ...
  192.168.50.11:14511 ...
  192.168.50.12:14500 ...
  192.168.50.12:14501 ...
...
```

### Note on layer examples ###

The examples that follow will assume that a container named `fdb` is running and
use it for the FoundationDB key-value store. For other configurations, whenever
it says ```--volumes-from fdb```, ```-v /etc/foundationdb/fdb.cluster:/etc/foundationdb/fdb.cluster:r``` would work just as well.

## SQL Layer ##

### Build images ###

```bash
docker build -t foundationdb/fdb-client fdb-client
docker build -t foundationdb/oracle-jdk8 oracle-jdk8
docker build -t foundationdb/sql-layer-client sql-layer-client
docker build -t foundationdb/sql-layer sql-layer
```

### Starting and checking SQL Layer ###

If the SQL Layer client is installed on the Docker host, it can access the
container directly.

```bash
CONT=$(docker run -d --volumes-from fdb foundationdb/sql-layer)
# (wait a bit and run on Docker host)
fdbsqlcli -h $(docker inspect --format='{{.NetworkSettings.IPAddress}}' $CONT)
```

If the Docker host is running under Vagrant and forwarding some ports to it, the
client can be run on the Vagrant host.

```bash
docker run -d --volumes-from fdb -p 49432:15432 foundationdb/sql-layer
# (wait a bit and run on Vagrant host)
fdbsqlcli -p 49432
```

Or the SQL client can be run in its own container, linked to the SQL Layer in
order to see its exposed ports.

```bash
docker run -d --volumes-from fdb --name sql foundationdb/sql-layer
docker run --rm -t -i --link sql:sql foundationdb/sql-layer-client
```

```sql
CREATE TABLE t1(id INT PRIMARY KEY, s VARCHAR(16));
INSERT INTO t1 VALUES(1, 'Fred'),(2, 'Wilma');
exit
```

It is also possible to pass client arguments into the container.

```bash
docker run --rm -t -i --link sql:sql -e 'FDBSQLCLI_ARGS=-c "SELECT s FROM t1"' foundationdb/sql-layer-client
```

### Multiple SQL Layers ###

More than one SQL Layer container can run against the same FDB cluster /
container(s).  They will share data.

```bash
docker run -d --volumes-from fdb --name sql2 foundationdb/sql-layer
docker run --rm -t -i --link sql2:sql foundationdb/sql-layer-client
```

```sql
SELECT * FROM t1;
exit
```

## SQL Layer pooling ##

### PGPool-II ###

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

### HAProxy ###

```bash
docker build -t foundationdb/haproxy haproxy
docker run -d --volumes-from fdb --name sql foundationdb/sql-layer
docker run -d --volumes-from fdb --name sql2 foundationdb/sql-layer
docker run -d --link sql:fdbsql --link sql2:fdbsql2 --name haproxy foundationdb/haproxy
```

Unlike PGPool, this setup will not provide any connection pooling. Each time a
client connects, the proxy will decide which of the actual servers to use. But a
client-side pool can be used.

### HikariCP test ###

Using the SQL Layers directly, the connection pool will always use the first
host that is up.

```bash
docker build -t hikaricp-test hikaricp-test
docker run --rm --link sql:fdbsql --link sql2:fdbsql2 hikaricp-test
```

Adding HAProxy will give both failover and load balancing.

```bash
docker run --rm --link haproxy:fdbsql hikaricp-test
```

## SQL Layer security ##

### LDAP ###

Build images:

```bash
docker build -t ldap-server ldap-server
docker build -t ldap-sql-layer ldap-sql-layer
```

Start a LDAP server with local users:

```bash
docker run -d --name ldap ldap-server
```

Start a SQL layer that will use that server:

```bash
docker run -d --volumes-from fdb --link ldap:ldap -e LDAP_CONFIG=jetty1 --name ldapsql ldap-sql-layer
```

A SQL client will be authenticated and have admin access only if user
is a member of that group:

```bash
docker run --rm -t -i --link ldapsql:sql -e FDBSQLCLI_ARGS="-u fred -w wilma" foundationdb/sql-layer-client
docker run --rm -t -i --link ldapsql:sql -e FDBSQLCLI_ARGS="-u wilma -w fred" foundationdb/sql-layer-client
```

### Kerberos ###

Build images:

```bash
docker build -t krb5-server krb5-server
docker build -t krb5-sql-layer krb5-sql-layer
docker build -t krb5-sql-layer-client krb5-sql-layer-client
```

Start a KDC:

```bash
docker run -d --name kdc krb5-server
```

Start a SQL layer that will register itself with the KDC:

```bash
docker run -d --volumes-from fdb --link kdc:kdc --name krbsql krb5-sql-layer
```

A SQL client that will authenticate with the KDC and then use that ticket with the SQL
layer:

```bash
docker run --rm -t -i --link kdc:kdc -e KRB_USER=user --link krbsql:sql krb5-sql-layer-client
```

The password is secret.

Add the necessary role for REST access:

```sql
CALL security_schema.add_role('rest-user');
CALL security_schema.add_role('admin');
CALL security_schema.add_user('user', 'secret', 'rest-user,admin');
```

Which is then authenticated by the same KDC:

```bash
docker run --rm -t -i --link kdc:kdc -e KRB_USER=user --link krbsql:sql -e REST_ARGS="/v1/version" krb5-sql-layer-rest-client
```

## Applications ##

### A simple PHP page ###

```bash
docker build -t foundationdb/lefp lefp
docker run -d --volumes-from fdb --name phpsql foundationdb/sql-layer
docker run -d --link phpsql:fdbsql -p 49080:80 foundationdb/lefp
```

PHP will be at [localhost:49080](http://localhost:49080/).

### Ruby on Rails : Spree Commerce ###

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

### MyBatis JPetStore sample ###

```bash
docker build -t foundationdb/tomcat tomcat
docker build -t foundationdb/mybatis-jpetstore mybatis-jpetstore
docker run -d -p 49088:8080 --link sql:sql foundationdb/mybatis-jpetstore
```

Store will be at [localhost:49088](http://localhost:49088/jpetstore/).

### Activiti ###

```bash
docker build -t foundationdb/tomcat tomcat
docker build -t foundationdb/activiti activiti
docker run -d -p 49089:8080 --link sql:sql foundationdb/activiti
```

Explorer will be at [localhost:49089](http://localhost:49089/activiti-webapp-explorer2).

## ORM testing ###

### Doctrine DBAL PHPUnit ###

```bash
docker build -t dbal-test doctrine-dbal-phpunit
docker run --link phpsql:fdbsql dbal-test
```

### SQLAlchemy FoundationDB SQL PyTest ###

```bash
docker build -t sqlalchemy-test sqlalchemy-pytest
docker run --link sql:fdbsql sqlalchemy-test
```

## Vagrant ##

A Vagrantfile is included which provisions one or more Docker hosts running CoreOS.

This allows the scripts to be run on Windows, given a machine with sufficient
RAM, and for testing the interaction among several Docker hosts.

The following environment variables refine the behavior of `vagrant up`.

* `VAGRANT_SYNC_TYPE`: `rsync` to use rsync for a one-way copy of this directory
onto the Docker host, `nfs` to do a two-way mount, though writing back seems to
be quite slow with the Windows server.

* `DOCKER_BOX_COUNT`: to several Docker hosts at once. If more than one is
specified, they will all be on a private network and have (insecure!) SSH
access to one another. The first box will have all the Docker images and any
others will have the `fdb-server` and `fdb-client` images for setting up a cluster.

