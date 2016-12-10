#
# Ruby backup gem service docker image
#
# http://github.com/tenstartups/backup-service-docker
#

FROM tenstartups/alpine:latest

MAINTAINER Marc Lennox <marc.lennox@gmail.com>

# Set environment variables.
ENV \
  HOME=/home/backups \
  BACKUP_CONFIG_DIR=/etc/backups \
  BACKUP_DATA_DIR=/var/lib/backups \
  PG_VERSION=9.6.1

# Install base packages.
RUN \
  apk --update add \
    build-base \
    git \
    libxml2-dev \
    libxslt-dev \
    mysql-client \
    openssl-dev \
    readline-dev \
    redis \
    rsync \
    ruby \
    ruby-bigdecimal \
    ruby-bundler \
    ruby-dev \
    ruby-irb \
    ruby-io-console \
    ruby-json \
    ruby-rake \
    sqlite \
    tar \
    zlib-dev && \
  rm -rf /var/cache/apk/*

# Install postgresql
RUN wget ftp://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2 -O /tmp/postgresql-${PG_VERSION}.tar.bz2 && \
    tar xvfj /tmp/postgresql-${PG_VERSION}.tar.bz2 -C /tmp && \
    cd /tmp/postgresql-${PG_VERSION} && \
    ./configure --enable-integer-datetimes --enable-thread-safety --prefix=/usr/local --with-libedit-preferred --with-openssl && \
    make world && \
    make install world && \
    make -C contrib install && \
    cd /tmp/postgresql-${PG_VERSION}/contrib && \
    make && make install && \
    rm -r /tmp/postgresql-${PG_VERSION}*

# Install ruby gems.
RUN \
  cd /tmp && \
  git clone https://github.com/tenstartups/backup.git && \
  cd backup && \
  git checkout package_with_storage_id && \
  gem build backup.gemspec && \
  gem install backup --no-document && \
  gem install backup --local --ignore-dependencies --no-document && \
  cd .. && \
  rm -rf backup

# Define working directory.
WORKDIR /home/backups

# Define mountable directories.
VOLUME ["/home/backups", "/etc/backups", "/var/lib/backups", "/var/log/backups"]

# Add files to the container.
COPY entrypoint.sh /docker-entrypoint
COPY perform-backup.sh /usr/local/bin/perform-backup

# Set the entrypoint script.
ENTRYPOINT ["/docker-entrypoint"]
