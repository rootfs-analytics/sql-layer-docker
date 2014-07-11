# Spree Commerce running with FDB SQL Layer

FROM foundationdb/rvm-ruby

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get update
RUN apt-get -y install git imagemagick libpq-dev

ADD install.sh /tmp/
ADD database.yml /tmp/
RUN /tmp/install.sh

ADD unicorn.rb /thestore/config/
ADD run.sh /thestore/

EXPOSE 8080
VOLUME ["/static"]
WORKDIR /thestore
ENTRYPOINT ["/bin/bash", "/thestore/run.sh"]
