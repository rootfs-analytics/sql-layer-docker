# beastmaster: installs Beastmaster Labs project

FROM foundationdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get update
RUN apt-get -y install build-essential python-dev git

RUN easy_install foundationdb
RUN easy_install twisted
#RUN git clone git@bitbucket.org:mmcm/beastmaster.git
ADD beastmaster.tar.gz /
