# fdb-client: installs client libraries (without fdb.cluster).

FROM ubuntu:12.04

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get update # && apt-get -y upgrade
RUN apt-get -y install python-software-properties python-setuptools

ADD https://foundationdb.com/downloads/I_accept_the_FoundationDB_Community_License_Agreement/2.0.5/foundationdb-clients_2.0.5-1_amd64.deb /tmp/
RUN dpkg -i /tmp/foundationdb-clients_2.0.5-1_amd64.deb
