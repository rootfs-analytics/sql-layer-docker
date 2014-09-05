# tomcat: Run Tomcat7 app server

FROM foundationdb/sql-layer-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install tomcat7 tomcat7-admin

ADD tomcat-start.sh /

EXPOSE 8080

RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
