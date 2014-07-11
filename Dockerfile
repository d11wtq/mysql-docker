# Dockerfile for a MySQL container.
#
# Runs MySQL 5.6 on port 3306 with optional host persistence.

FROM       d11wtq/ubuntu
MAINTAINER Chris Corbyn <chris@w3style.co.uk>

RUN sudo apt-get update -qq -y
RUN sudo apt-get install -qq -y libncurses5-dev

RUN sudo apt-get install -qq -y cmake;                                     \
    cd /tmp;                                                               \
    curl -LO http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.19.tar.gz; \
    tar xvzf *.tar.gz; rm -f *.tar.gz;                                     \
    cd mysql*;                                                             \
    cmake .                                                                \
      -DCMAKE_INSTALL_PREFIX=/usr/local                                    \
      -DDEFAULT_CHARSET=utf8                                               \
      -DDEFAULT_COLLATION=utf8_general_ci                                  \
      -DMYSQL_DATADIR=/mysql/data                                          \
      -DSYSCONFDIR=/mysql                                                  \
      -DWITH_ARCHIVE_STORAGE_ENGINE=1                                      \
      -DWITH_BLACKHOLE_STORAGE_ENGINE=1                                    \
      -DWITH_FEDERATED_STORAGE_ENGINE=1                                    \
      -DWITH_INNOBASE_STORAGE_ENGINE=1                                     \
      -DWITH_PARTITION_STORAGE_ENGINE=1                                    \
      -DWITH_PERFSCHEMA_STORAGE_ENGINE=1                                   \
      -DENABLED_LOCAL_INFILE=1                                             \
      -DENABLED_PROFILING=1;                                               \
    make && make install;                                                  \
    cd; rm -rf /tmp/mysql*;                                                \
    sudo apt-get remove -qq -y cmake;                                      \
    sudo apt-get autoremove -qq -y

ADD mysql /mysql
RUN sudo chown -R default: /mysql/data

ADD scripts/init.sql /usr/local/scripts/
ADD bin/start_mysqld /usr/local/bin/start_mysqld
RUN sudo chmod 0755 /usr/local/bin/start_mysqld

EXPOSE 3306

CMD [ "/usr/local/bin/start_mysqld" ]
