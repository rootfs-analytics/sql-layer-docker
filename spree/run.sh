#!/bin/bash

source /usr/local/rvm/scripts/rvm

sed -i -e "s/localhost/$FDBSQL_PORT_15432_TCP_ADDR/g" config/database.yml

CMD=$1; shift
if [ "$CMD" = "shell" ]; then
  exec /bin/bash $@
fi

set -e

export RAILS_ENV=production 

if [ "$CMD" = "init" ]; then
  rake db:drop
  rake db:migrate
  AUTO_ACCEPT=true rake db:seed
  rake spree_sample:load
  rm -rf /static/assets /static/spree
  mv public/assets /static
  mv public/spree /static
fi

rm -rf public/assets public/spree
ln -s /static/assets public
ln -s /static/spree public

unicorn_rails -c config/unicorn.rb
