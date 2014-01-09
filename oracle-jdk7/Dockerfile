# oracle-jdk7: installs Oracle JDK on top of fdb-client.

FROM fdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update

RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get -y install oracle-java7-installer && apt-get clean
