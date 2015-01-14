# krb5-sql-layer-rest-client: runs curl client with Kerberos authentication

FROM foundationdb/sql-layer-rest-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install krb5-user

ADD krb5.conf /etc/

ADD krb5-restclient.sh /
CMD /krb5-restclient.sh

# TODO: Version of curl in 14.04 is still too old (need 7.38) and
# SPNEGO negotation doesn't really work. So build from source.
RUN apt-get -y remove curl libcurl3
ADD http://curl.haxx.se/download/curl-7.40.0.tar.gz /tmp/
RUN apt-get -y update
RUN apt-get -y install build-essential libgcrypt11-dev libgnutls-dev libidn11-dev libkrb5-dev libldap2-dev libnss3-dev librtmp-dev libssl-dev libtool openssh-server quilt zlib1g-dev
RUN cd /tmp && tar fvxz curl-7.40.0.tar.gz && cd curl-7.40.0 && ./configure --with-gssapi && make && make install && cd .. && rm -rf curl-7.40.0*
RUN ldconfig
