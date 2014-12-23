# haproxy: Load balancer for multiple SQL layer instances

FROM foundationdb/sql-layer-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install haproxy

ADD docker-haproxy.sh /

EXPOSE 8080 8091 15432

RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
