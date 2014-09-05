#!/bin/bash

DESTDIR=/
TMPDIR=/tmp
WARDIR=/tmp/jpetstore

unzip $1 "$2/$2.war" -d $TMPDIR

rm -rf $WARDIR
mkdir -p $WARDIR
(cd $WARDIR && jar xf "$TMPDIR/$2/$2.war")

rm $WARDIR/WEB-INF/lib/hsqldb-*.jar
cp /usr/share/foundationdb/sql/client/fdb*.jar $WARDIR/WEB-INF/lib/

patch -p 3 -d $WARDIR <<EOF
*** /tmp/jpetstore.orig/WEB-INF/applicationContext.xml	2011-06-04 08:25:04.000000000 -0400
--- /tmp/jpetstore//WEB-INF/applicationContext.xml	2014-09-05 16:07:08.265975201 -0400
***************
*** 28,38 ****
       http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-3.0.xsd
       http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">
  
!    <!-- in-memory database and a datasource -->
      <jdbc:embedded-database id="dataSource">
          <jdbc:script location="classpath:database/jpetstore-hsqldb-schema.sql"/>
          <jdbc:script location="classpath:database/jpetstore-hsqldb-dataload.sql"/>
      </jdbc:embedded-database>
  
      <!-- transaction manager, use JtaTransactionManager for global tx -->
      <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
--- 28,50 ----
       http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-3.0.xsd
       http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-3.0.xsd">
  
!    <!-- in-memory database and a datasource
      <jdbc:embedded-database id="dataSource">
          <jdbc:script location="classpath:database/jpetstore-hsqldb-schema.sql"/>
          <jdbc:script location="classpath:database/jpetstore-hsqldb-dataload.sql"/>
      </jdbc:embedded-database>
+     -->
+ 
+     <bean id="propertyConfigurer" class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
+         <property name="location" value="file:///var/lib/tomcat7/conf/fdbsql.properties" />
+     </bean>
+ 
+     <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
+         <property name="driverClassName" value="com.foundationdb.sql.jdbc.Driver"/>
+         <property name="url" value="jdbc:fdbsql://\${fdbsql.host}:15432/jpetstore"/>
+         <property name="username" value="test"/>
+         <property name="password" value="test"/>
+     </bean>
  
      <!-- transaction manager, use JtaTransactionManager for global tx -->
      <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
EOF

cat $WARDIR/WEB-INF/classes/database/jpetstore-hsqldb-schema.sql $WARDIR/WEB-INF/classes/database/jpetstore-hsqldb-dataload.sql >$DESTDIR/jpetstore.sql
rm -rf $WARDIR/WEB-INF/classes/database

jar cf $DESTDIR/jpetstore.war -C $WARDIR .
