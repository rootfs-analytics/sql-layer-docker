# spree-nginx: Web server for Spree app server(s)

FROM foundationdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install nginx

#RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >>/etc/nginx/nginx.conf

ADD nginx-site /etc/nginx/sites-available/default
ADD nginx-start.sh /

EXPOSE 80

RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
