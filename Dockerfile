#
# Ruby backup gem service dockerfile
#
# http://github.com/tenstartups/backup-service-docker
#

FROM debian:jessie

MAINTAINER Marc Lennox <marc.lennox@gmail.com>

# Set environment variables.
ENV \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm-color \
  HOME=/home/backups \
  BACKUP_CONFIG_DIR=/etc/backups \
  BACKUP_DATA_DIR=/var/lib/backups

# Install base packages.
RUN \
  apt-get update && \
  apt-get -y install \
    build-essential \
    cron \
    curl \
    daemontools \
    git \
    inotify-tools \
    libcurl4-openssl-dev \
    libffi-dev \
    libreadline6-dev \
    libssl-dev \
    libsqlite3-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    mysql-client \
    nano \
    python \
    python-setuptools \
    sqlite3 \
    wget \
    zlib1g-dev

# Install supervisord using easy install.
RUN easy_install supervisor

# Add postgresql client from official source.
RUN \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  wget https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
  apt-key add ACCC4CF8.asc && \
  apt-get update && \
  apt-get -y install libpq-dev postgresql-client-9.4 postgresql-contrib-9.4

# Compile redis from official source
RUN \
  cd /tmp && \
  wget http://download.redis.io/releases/redis-2.8.19.tar.gz && \
  tar -xzvf redis-*.tar.gz && \
  rm -f redis-*.tar.gz && \
  cd redis-* && \
  make && \
  make install && \
  cd .. && \
  rm -rf redis-*

# Compile ruby from source.
RUN \
  cd /tmp && \
  wget http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.0.tar.gz && \
  tar -xzvf ruby-*.tar.gz && \
  rm -f ruby-*.tar.gz && \
  cd ruby-* && \
  ./configure --disable-install-doc && \
  make && \
  make install && \
  cd .. && \
  rm -rf ruby-*

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install ruby gems.
RUN gem install bundler --no-ri --no-rdoc

# Define working directory.
WORKDIR /opt/backups

# Define mountable directories.
VOLUME ["/home/backups", "/etc/backups", "/etc/schedule", "/var/lib/backups", "/var/log/backups"]

# Bundle gem files
ADD Gemfile /opt/backups/Gemfile
ADD Gemfile.lock /opt/backups/Gemfile.lock
RUN echo "gem: --no-ri --no-rdoc" > ${HOME}/.gemrc
RUN bundle install --without development test --deployment

# Add files to the container.
ADD . /opt/backups

# Copy scripts and configuration into place
RUN \
  find ./script -regex '^.+\.sh$' -exec bash -c 'mv "{}" "$(echo {} | sed -En ''s/\.\\/script\\/\(.*\)\.sh/\\/usr\\/local\\/bin\\/\\1/p'')"' \; && \
  mv ./conf/supervisord.conf /etc && \
  rm -rf ./script && \
  rm -rf ./conf

# Set the entrypoint script.
ENTRYPOINT ["./entrypoint"]

# Set the default command.
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
