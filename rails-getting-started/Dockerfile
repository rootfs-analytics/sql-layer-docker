# rails-getting-started: Getting Started code from Rails Docs running with FDB SQL Layer

FROM foundationdb/rvm-ruby

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get -y install git
RUN git clone https://github.com/rails/docrails
RUN cd docrails/guides/code/getting_started && sed -i -e "s|gem 'sqlite3'|gem 'activerecord-fdbsql-adapter', github: 'FoundationDB/sql-layer-adapter-activerecord'|g" Gemfile && sed -i -e "s|# gem 'therubyracer'|gem 'therubyracer'|g" Gemfile

RUN apt-get -y install libpq-dev
RUN bash -c "source /usr/local/rvm/scripts/rvm && cd docrails/guides/code/getting_started && bundle install"

EXPOSE 3000
ADD database.yml docrails/guides/code/getting_started/config/
CMD cd docrails/guides/code/getting_started && sed -i -e "s/localhost/$FDBSQL_PORT_15432_TCP_ADDR/g" config/database.yml && bash -c "source /usr/local/rvm/scripts/rvm && rake db:migrate && rails server -p 3000"
