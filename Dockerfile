#
# Ruby backup gem service dockerfile
#
# http://github.com/tenstartups/backup-service-docker
#

# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:latest

MAINTAINER Marc Lennox <marc.lennox@gmail.com>

# Set environment variables.
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Remove OS cron jobs
RUN rm -f /etc/cron.daily/*

# Install base packages.
RUN apt-get update
RUN apt-get -y install \
  build-essential \
  curl \
  git \
  inotify-tools \
  libcurl4-openssl-dev \
  libreadline-dev \
  libssl-dev \
  libsqlite3-dev \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  mysql-client \
  nano \
  sqlite3 \
  wget \
  zlib1g-dev

# Add postgresql client from official source.
RUN \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  wget https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
  apt-key add ACCC4CF8.asc && \
  apt-get update && \
  apt-get -y install libpq-dev postgresql-client-9.3 postgresql-contrib-9.3

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

# Install ruby gems.
RUN gem install bundler --no-ri --no-rdoc

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define working directory.
WORKDIR /opt/backup-service

# Bundle gem files
ADD Gemfile /opt/backup-service/Gemfile
ADD Gemfile.lock /opt/backup-service/Gemfile.lock
RUN echo "gem: --no-ri --no-rdoc" > ${HOME}/.gemrc
RUN bundle install --without development test --deployment

# Add files to the container.
ADD . /opt/backup-service

# Move scripts into proper location.
RUN \
  mkdir -p /etc/service/schedule-updated && \
  mv ./script/schedule-updated.sh /etc/service/schedule-updated/run && \
  find ./script -regex '^.+\.sh$' -exec bash -c 'mv "{}" "$(echo {} | sed -En ''s/\.\\/script\\/\(.*\)\.sh/\\/usr\\/local\\/bin\\/\\1/p'')"' \; && \
  rm -rf ./script

# Set environment
ENV BACKUP_CONFIG_DIR /etc/backup-service
ENV BACKUP_DATA_DIR /var/lib/backup-service

# Define mountable directories.
VOLUME ["/etc/backup-service", "/etc/schedule", "/var/lib/backup-service"]

# Define entrypoint script.
ENTRYPOINT ["./entrypoint"]

# Define default command.
CMD ["/sbin/my_init"]
