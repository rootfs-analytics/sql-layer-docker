# SQLAlchemy-PyTest: run unit tests for SQLAlchemy adapter.

FROM foundationdb/fdb-client

MAINTAINER "fdb-boston@foundationdb.com"

RUN apt-get update
RUN apt-get -y install git python-pip python-dev libpq-dev
RUN pip install pytest mock

RUN git clone https://github.com/FoundationDB/sql-layer-adapter-sqlalchemy.git
RUN cd sql-layer-adapter-sqlalchemy && python setup.py install

CMD cd sql-layer-adapter-sqlalchemy && py.test --dburi foundationdb+psycopg2://@$FDBSQL_PORT_15432_TCP_ADDR:15432/test
