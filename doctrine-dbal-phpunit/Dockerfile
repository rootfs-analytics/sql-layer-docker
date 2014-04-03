# Doctrine-DBAL-PHPUnit: run unit tests for Doctrine adapter.

FROM fdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install php5-cli php-pear php5-pgsql php5-sqlite

RUN pear channel-discover pear.phpunit.de
RUN pear channel-discover pear.symfony.com
RUN pear install --alldeps pear.phpunit.de/PHPUnit

ADD https://getcomposer.org/installer /tmp/
RUN php </tmp/installer
RUN mv composer.phar /usr/local/bin/composer

RUN apt-get -y install git
RUN git clone https://github.com/FoundationDB/sql-layer-adapter-doctine-dbal

RUN cd sql-layer-adapter-doctine-dbal && composer update && rm -rf vendor/doctrine && composer update --prefer-source && cd vendor/doctrine/dbal && composer update

# Temporary for 2.4.2.
ADD test.patch sql-layer-adapter-doctine-dbal/
RUN cd sql-layer-adapter-doctine-dbal/vendor/doctrine/dbal && patch -p 1 -d . <../../../test.patch

RUN cd sql-layer-adapter-doctine-dbal && cp phpunit.xml.dist phpunit.xml

CMD cd sql-layer-adapter-doctine-dbal && sed -i -e "s/localhost/$FDBSQL_PORT_15432_TCP_ADDR/g" phpunit.xml && phpunit
