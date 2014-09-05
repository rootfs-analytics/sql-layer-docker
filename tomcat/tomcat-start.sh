#!/bin/bash
ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASS=${ADMIN_PASS:-tomcat}

cat >/var/lib/tomcat7/conf/tomcat-users.xml <<EOF 
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
  <user username="${ADMIN_USER}" password="${ADMIN_PASS}" roles="admin-gui,manager-gui"/>
</tomcat-users>
EOF

cat >/var/lib/tomcat7/conf/fdbsql.properties <<EOF
fdbsql.host=${SQL_PORT_15432_TCP_ADDR}
EOF

for SQL in /*.sql; do
  SCHEMA=${SQL%.sql}
  SCHEMA=${SCHEMA#/}
  fdbsqlcli -h $SQL_PORT_15432_TCP_ADDR -s $SCHEMA -f $SQL --on-error EXIT SUCCESS
done

export CATALINA_BASE=/var/lib/tomcat7
/bin/sh -e /usr/share/tomcat7/bin/catalina.sh run
