# hikaricp: JVM client-side connection pool using HikariCP

FROM foundationdb/sql-layer-client

MAINTAINER "fdb-boston@foundationdb.com"

ADD https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein /usr/local/bin/
ENV LEIN_ROOT yes
RUN chmod a+x /usr/local/bin/lein && lein upgrade

RUN apt-get -y install git
# Temporary
RUN git clone -b jdbc-url-option https://github.com/MMcM/hikari-cp.git && cd hikari-cp && lein install
RUN git clone https://github.com/MMcM/hikari-cp-test.git && cd hikari-cp-test && lein uberjar

ADD hikaricp-test.sh /hikari-cp-test/
CMD /hikari-cp-test/hikaricp-test.sh 10
