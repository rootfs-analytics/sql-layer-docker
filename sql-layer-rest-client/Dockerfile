# sql-layer-rest-client: runs curl client against linked host

FROM foundationdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install curl
ADD http://stedolan.github.io/jq/download/linux64/jq /usr/local/bin/
RUN chmod a+x /usr/local/bin/jq

ADD restclient.sh /
CMD /restclient.sh
