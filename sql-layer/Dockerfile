# sql-layer: installs SQL layer on top of JDK + FDB client

FROM fdb/oracle-jdk7

MAINTAINER "fdb-boston@foundationdb.com"

ADD https://s3.amazonaws.com/foundationdb/downloads/I_accept_the_FoundationDB_Community_License_Agreement/sql-layer/1.9.3/fdb-sql-layer_1.9.3-1_all.deb /tmp/
RUN dpkg -i /tmp/fdb-sql-layer_1.9.3-1_all.deb

RUN mv /etc/foundationdb/sql /etc/fdb-sql

EXPOSE 15432

ADD docker-sql-layer.sh /usr/lib/foundationdb/

RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
