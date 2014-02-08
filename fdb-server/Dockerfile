# fdb-server: installs FDB server running in container

FROM fdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

# Prevent initialization by installer
RUN mkdir /etc/foundationdb && touch /etc/foundationdb/fdb.cluster

ADD https://foundationdb.com/downloads/I_accept_the_FoundationDB_Community_License_Agreement/2.0.0/foundationdb-server_2.0.0-1_amd64.deb /tmp/
RUN dpkg -i /tmp/foundationdb-server_2.0.0-1_amd64.deb

RUN mv /etc/foundationdb/foundationdb.conf /usr/lib/foundationdb/foundationdb.conf.orig
RUN rm -rf /etc/foundationdb /var/lib/foundationdb/data
VOLUME ["/etc/foundationdb", "/fdb-data"]

EXPOSE 4500

ADD docker-start.sh /usr/lib/foundationdb/

RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
