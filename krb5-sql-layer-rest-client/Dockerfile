# krb5-sql-layer-rest-client: runs curl client with Kerberos authentication

FROM foundationdb/sql-layer-rest-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install krb5-user

ADD krb5.conf /etc/

ADD krb5-restclient.sh /
CMD /krb5-restclient.sh
