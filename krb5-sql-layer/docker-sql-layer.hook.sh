
sed -i -e "s/kdc.docker.local/$KDC_PORT_88_UDP_ADDR/g" /etc/krb5.conf

if [ ! -f /etc/foundationdb/sql/fdbsql.keytab ]; then

    SERVER_PRINC=postgres/krbsql.docker.local

    kadmin -p user/admin <<EOF
top-secret
add_principal -randkey $SERVER_PRINC
ktadd -k /etc/foundationdb/sql/fdbsql.keytab $SERVER_PRINC
EOF

    chown foundationdb:foundationdb /etc/foundationdb/sql/fdbsql.keytab

    cat >/etc/foundationdb/sql/jaas.conf <<EOF
krbsql {
    com.sun.security.auth.module.Krb5LoginModule required
    storeKey=true
    useKeyTab=true
    keyTab="/etc/foundationdb/sql/fdbsql.keytab"
    principal="$SERVER_PRINC@docker.local"
    isInitiator=false;
};
EOF

    cat >>/etc/foundationdb/sql/server.properties <<EOF

fdbsql.postgres.gssConfigName=krbsql
EOF

    cat >>/etc/foundationdb/sql/jvm.options <<EOF

JVM_OPTS="\$JVM_OPTS -Djava.security.auth.login.config=/etc/foundationdb/sql/jaas.conf"
EOF

fi
