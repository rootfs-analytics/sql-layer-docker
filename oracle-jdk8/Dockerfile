# oracle-jdk8: installs Oracle JDK on top of fdb-client.

FROM foundationdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get update
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get -y install oracle-java8-installer && apt-get clean
