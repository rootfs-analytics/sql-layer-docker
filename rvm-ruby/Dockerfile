# rvm-ruby: install Ruby using RVM

FROM fdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install curl
ADD https://get.rvm.io rvm-installer
RUN bash -s stable --ruby <rvm-installer
