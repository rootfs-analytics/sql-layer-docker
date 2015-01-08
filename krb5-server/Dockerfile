# krb5-server: Kerberos server inside container

FROM foundationdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install krb5-kdc krb5-admin-server

ADD krb5.conf /etc/
ADD kadm5.acl /etc/krb5kdc/
ADD kadmin.principals /tmp/

RUN sed -i -e "s/kdc.docker.local/localhost/g" /etc/krb5.conf

RUN kdb5_util create -s -P secret
RUN kadmin.local </tmp/kadmin.principals

EXPOSE 88/udp 464 464/udp 749 750/udp

RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
