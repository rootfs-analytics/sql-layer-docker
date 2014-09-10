# sql-layer-client: runs SQL client against linked host

FROM foundationdb/oracle-jdk7

MAINTAINER "fdb-boston@foundationdb.com"

ADD https://foundationdb.com/downloads/I_accept_the_FoundationDB_Community_License_Agreement/sql-layer/2.0.latest/fdb-sql-layer-client-tools_2.0.latest-1_all.deb /tmp/
RUN dpkg -i /tmp/fdb-sql-layer-client-tools_2.0.latest-1_all.deb

CMD fdbsqlcli -h $SQL_PORT_15432_TCP_ADDR
