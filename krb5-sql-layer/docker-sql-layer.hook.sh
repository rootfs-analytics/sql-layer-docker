
sed -i -e "s/kdc.docker.local/$KDC_PORT_88_UDP_ADDR/g" /etc/krb5.conf

if [ ! -f /etc/foundationdb/sql/fdbsql.keytab ]; then

    KRB_REALM=DOCKER.LOCAL
    FDBSQL_PRINC=fdbsql/krbsql.docker.local
    FDBSQL_KEYTAB=/etc/foundationdb/sql/fdbsql.keytab
    REST_PRINC=HTTP/krbsql.docker.local
    REST_KEYTAB=/etc/foundationdb/sql/rest.keytab

    kadmin -p user/admin <<EOF
top-secret
add_principal -randkey $FDBSQL_PRINC
ktadd -k $FDBSQL_KEYTAB $FDBSQL_PRINC
add_principal -randkey $REST_PRINC
ktadd -k $REST_KEYTAB $REST_PRINC
EOF

    chown foundationdb:foundationdb /etc/foundationdb/sql/*.keytab

    cat >/etc/foundationdb/sql/jaas.conf <<EOF
krbsql {
    com.sun.security.auth.module.Krb5LoginModule required
    storeKey=true
    useKeyTab=true
    keyTab="$FDBSQL_KEYTAB"
    principal="$FDBSQL_PRINC@$KRB_REALM"
    isInitiator=false;
};

com.sun.security.jgss.accept {
    com.sun.security.auth.module.Krb5LoginModule required
    storeKey=true
    useKeyTab=true
    keyTab="$REST_KEYTAB"
    principal="$REST_PRINC@$KRB_REALM"
    isInitiator=false;
};
EOF

    cat >>/etc/foundationdb/sql/server.properties <<EOF

fdbsql.restrict_user_schema=true
fdbsql.postgres.gssConfigName=krbsql
fdbsql.http.login=spnego
fdbsql.http.spnego.targetName=$REST_PRINC@$KRB_REALM
fdbsql.security.realm=$KRB_REALM
EOF

    cat >>/etc/foundationdb/sql/jvm.options <<EOF

JVM_OPTS="\$JVM_OPTS -Djava.security.auth.login.config=/etc/foundationdb/sql/jaas.conf -Djavax.security.auth.useSubjectCredsOnly=false"
EOF

fi
