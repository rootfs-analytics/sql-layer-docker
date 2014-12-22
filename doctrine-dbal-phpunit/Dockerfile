# Doctrine-DBAL-PHPUnit: run unit tests for Doctrine adapter.

FROM foundationdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install php5-cli php5-pgsql php5-sqlite

ADD https://getcomposer.org/installer /tmp/
RUN php </tmp/installer
RUN mv composer.phar /usr/local/bin/composer

RUN apt-get -y install git
#RUN git clone https://github.com/FoundationDB/sql-layer-adapter-doctine-dbal
RUN git clone -b version-update https://github.com/MMcM/sql-layer-adapter-doctine-dbal

RUN cd sql-layer-adapter-doctine-dbal && composer update && rm -rf vendor/doctrine && composer update --prefer-source && cd vendor/doctrine/dbal && composer update

RUN cd sql-layer-adapter-doctine-dbal && cp phpunit.xml.dist phpunit.xml

CMD cd sql-layer-adapter-doctine-dbal && sed -i -e "s/localhost/$FDBSQL_PORT_15432_TCP_ADDR/g" phpunit.xml && vendor/bin/phpunit
