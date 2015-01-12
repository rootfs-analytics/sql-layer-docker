# krb5-sql-layer-client: SQL layer client using Kerberos authentication

FROM foundationdb/sql-layer-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install krb5-user oracle-java8-unlimited-jce-policy

ADD krb5.conf /etc/

ADD jaas.conf /root/.java.login.config

ADD krb-fdbsqlcli.sh /
CMD /krb-fdbsqlcli.sh
