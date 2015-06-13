#
# Ruby backup gem service docker image
#
# http://github.com/tenstartups/backup-service-docker
#

FROM ruby:slim

MAINTAINER Marc Lennox <marc.lennox@gmail.com>

# Set environment variables.
ENV \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm-color \
  HOME=/home/backups \
  BACKUP_CONFIG_DIR=/etc/backups \
  BACKUP_DATA_DIR=/var/lib/backups

# Install base packages.
RUN apt-get update && apt-get -y install \
  build-essential \
  cron \
  curl \
  git \
  inotify-tools \
  mysql-client \
  nano \
  python \
  python-pip \
  python-setuptools \
  sqlite3 \
  wget

# Install supervisord and plugins.
RUN \
  easy_install supervisor && \
  pip install supervisor-stdout

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
  wget http://download.redis.io/redis-stable.tar.gz && \
  tar -xzvf redis-*.tar.gz && \
  rm -f redis-*.tar.gz && \
  cd redis-* && \
  make && \
  make install && \
  cd .. && \
  rm -rf redis-*

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install ruby gems.
RUN gem install backup listen whenever --no-ri --no-rdoc

# Define working directory.
WORKDIR /home/backups

# Define mountable directories.
VOLUME ["/home/backups", "/etc/backups", "/etc/schedule", "/var/lib/backups", "/var/log/backups"]

# Add files to the container.
ADD . /home/backups

# Copy scripts and configuration into place.
RUN \
  find ./script -regextype posix-extended -regex '^.+\.(rb|sh)\s*$' -exec bash -c 'f=`basename "{}"`; mv -v "{}" "/usr/local/bin/${f%.*}"' \; && \
  rm -rf ./script && \
  mv ./conf/supervisord.conf /etc && \
  rm -rf ./conf

# Set the entrypoint script.
ENTRYPOINT ["./entrypoint"]

# Set the default command.
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf"]
