# krb5-sql-layer: SQL layer using Kerberos authentication

FROM foundationdb/sql-layer

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install krb5-user oracle-java8-unlimited-jce-policy

ADD krb5.conf /etc/

ADD docker-sql-layer.hook.sh /usr/lib/foundationdb/
