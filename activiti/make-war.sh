#!/bin/bash

DESTDIR=/
TMPDIR=/tmp
WARDIR=/tmp/activiti-webapp

unzip $1 -d $TMPDIR
SRCDIR=$TMPDIR/$2

cd $SRCDIR
mvn -Pdistro clean install -Dmaven.test.skip

rm -rf $WARDIR
mkdir -p $WARDIR
(cd $WARDIR && jar xf $SRCDIR/modules/activiti-webapp-explorer2/target/activiti-webapp-explorer2-*-SNAPSHOT.war)

rm $WARDIR/WEB-INF/lib/h2-*.jar
cp /usr/share/foundationdb/sql/client/fdb*.jar $WARDIR/WEB-INF/lib/

sed -i -e 's|<property name="location" value="classpath:db.properties" />|<property name="locations"><list><value>file:///var/lib/tomcat7/conf/fdbsql.properties</value><value>classpath:db.properties</value></list></property>|' $WARDIR/WEB-INF/activiti-standalone-context.xml

cat >$WARDIR/WEB-INF/classes/db.properties <<EOF
db=fdbsql
jdbc.driver=com.foundationdb.sql.jdbc.Driver
jdbc.url=jdbc:fdbsql://\${fdbsql.host}:15432/activiti
jdbc.username=activiti
jdbc.password=activiti
EOF

jar cf $DESTDIR/activiti-webapp-explorer2.war -C $WARDIR .
