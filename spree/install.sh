#!/bin/bash

source /usr/local/rvm/scripts/rvm

gem install rails --version 4.1.2 --no-document

rails _4.1.2_ new thestore --skip-bundle
cd thestore

sed -i -e "s|gem 'sqlite3'|gem 'activerecord-fdbsql-adapter', github: 'FoundationDB/sql-layer-adapter-activerecord'|g" Gemfile
mv /tmp/database.yml config/

sed -i -e "s|# gem 'therubyracer'|gem 'therubyracer'|g" Gemfile
sed -i -e "s|# gem 'unicorn'|gem 'unicorn'|g" Gemfile

cat >>Gemfile <<EOF
gem 'spree', '2.3.1'
gem 'spree_gateway', github: 'spree/spree_gateway', :branch => '2-3-stable'
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', :branch => '2-3-stable'
gem 'spree_i18n', github: 'spree/spree_i18n', branch: '2-3-stable'
EOF

bundle install

rails g spree:install --migrate=false --seed=false --sample=false

sed -i -e "s|'SQLite'|'SQLite','FDBSQL'|g" db/migrate/*_move_order_token_from_tokenized_permission.spree.rb
sed -i -e "s|def change|def change\n    Spree::Preference.reset_column_information|g" db/migrate/*_create_store_from_preferences.spree.rb

SECRET=$(rake secret)
cat >config/initializers/devise.rb <<EOF
Devise.secret_key = "${SECRET}"
EOF

SECRET=$(rake secret)
sed -i -e "s|<%= ENV\[\"SECRET_KEY_BASE\"\] %>|$SECRET|g" config/secrets.yml

RAILS_ENV=production rake assets:precompile

cat >>config/initializers/spree.rb <<EOF
Spree::Config.set(:allow_ssl_in_production => false)
EOF
