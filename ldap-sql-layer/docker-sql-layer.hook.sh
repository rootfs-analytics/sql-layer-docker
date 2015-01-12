
cp /tmp/jaas.conf /etc/foundationdb/sql/

sed -i -e "s/ldap.docker.local/$LDAP_PORT_389_TCP_ADDR/g" /etc/foundationdb/sql/jaas.conf

if [ -n "$LDAP_CONFIG" ]; then
    cat >>/etc/foundationdb/sql/server.properties <<EOF

fdbsql.restrict_user_schema=true
fdbsql.http.login=basic
fdbsql.sql.jaas.configName=$LDAP_CONFIG
EOF

    if [ "$LDAP_CONFIG" = "jetty1" ]; then
        cat >>/etc/foundationdb/sql/server.properties <<EOF
fdbsql.sql.jaas.roleClasses=org.eclipse.jetty.plus.jaas.JAASRole
EOF
    fi
fi

cat >>/etc/foundationdb/sql/jvm.options <<EOF
JVM_OPTS="\$JVM_OPTS -Djava.security.auth.login.config=/etc/foundationdb/sql/jaas.conf"
EOF
