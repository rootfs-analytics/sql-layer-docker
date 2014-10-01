# pgpool: Connection pool for multiple SQL layer instances

FROM foundationdb/sql-layer-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install pgpool2

EXPOSE 15432

ADD docker-pgpool.sh /

RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
