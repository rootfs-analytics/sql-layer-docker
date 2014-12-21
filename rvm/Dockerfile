# rvm: install RVM

FROM foundationdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN apt-get -y install curl
ADD https://get.rvm.io rvm-installer
RUN bash -s stable <rvm-installer
