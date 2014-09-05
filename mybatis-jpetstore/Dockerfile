# MyBatis sample application

FROM foundationdb/tomcat

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install unzip patch

ADD https://github.com/mybatis/jpetstore-6/releases/download/mybatis-jpetstore-6.0.1/mybatis-jpetstore-6.0.1-bundle.zip /tmp/

ADD make-war.sh /tmp/
RUN /tmp/make-war.sh /tmp/mybatis-jpetstore-6.0.1-bundle.zip mybatis-jpetstore-6.0.1
RUN mv /jpetstore.war /var/lib/tomcat7/webapps/
