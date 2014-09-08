# Activiti explorer

FROM foundationdb/tomcat

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install unzip maven

ADD https://github.com/MMcM/Activiti/archive/fdbsql.zip /tmp/Activiti-fdbsql.zip
ADD make-war.sh /tmp/
RUN /tmp/make-war.sh /tmp/Activiti-fdbsql.zip Activiti-fdbsql
RUN mv /activiti-webapp-explorer2.war /var/lib/tomcat7/webapps/
