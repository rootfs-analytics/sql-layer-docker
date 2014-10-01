# sql-layer: installs SQL layer on top of JDK + FDB client

FROM foundationdb/sql-layer-client

MAINTAINER "fdb-boston@foundationdb.com"

# ADD http://landfill.boston.foundationdb.com/share/packages/latest/fdb-sql-layer.deb /tmp/
# ADD fdb-sql-layer.deb /tmp/
ADD https://foundationdb.com/downloads/I_accept_the_FoundationDB_Community_License_Agreement/sql-layer/2.0.latest/fdb-sql-layer_2.0.latest-1_all.deb /tmp/fdb-sql-layer.deb
RUN dpkg -i /tmp/fdb-sql-layer.deb

RUN echo 'fdbsql.postgres.host=0.0.0.0' >>/etc/foundationdb/sql/server.properties
RUN mv /etc/foundationdb/sql /etc/fdb-sql

EXPOSE 15432

ADD docker-sql-layer.sh /usr/lib/foundationdb/

RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
