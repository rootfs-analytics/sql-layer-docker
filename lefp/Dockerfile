# LEFP: Linux + Nginx + FDB SQL Layer + PHP.

FROM fdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list
RUN add-apt-repository -y ppa:nginx/stable
RUN add-apt-repository -y ppa:ondrej/php5
RUN apt-get update && apt-get -y upgrade

RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl
RUN apt-get -y install nginx php5-fpm php5-pgsql

#RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >>/etc/nginx/nginx.conf

RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN echo "env[FDBSQL_PORT_15432_TCP_ADDR] = \$FDBSQL_PORT_15432_TCP_ADDR" >>/etc/php5/fpm/php-fpm.conf

ADD nginx-site /etc/nginx/sites-available/default
RUN mkdir -p /var/www
ADD index.php /var/www/
ADD phpinfo.php /var/www/
RUN chown -R www-data:www-data /var/www

EXPOSE 80

RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
