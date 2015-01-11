# ldap-server: LDAP server inside container

FROM foundationdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

ADD debconf.selections /tmp/

RUN debconf-set-selections </tmp/debconf.selections

RUN apt-get -y install slapd

ADD users.ldif /tmp/

RUN slapadd -l /tmp/users.ldif -F /etc/ldap/slapd.d

EXPOSE 389 389/udp

RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
