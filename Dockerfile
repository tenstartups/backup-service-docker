#
# Ruby backup gem service docker image
#
# http://github.com/tenstartups/backup-service-docker
#

FROM tenstartups/alpine-ruby:latest

MAINTAINER Marc Lennox <marc.lennox@gmail.com>

# Set environment variables.
ENV \
  TERM=xterm-color \
  HOME=/home/backups \
  BACKUP_CONFIG_DIR=/etc/backups \
  BACKUP_DATA_DIR=/var/lib/backups

# Install base packages.
RUN \
  echo 'http://dl-4.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories && \
  apk --update add git libxslt-dev libxml2-dev mysql-client postgresql redis sqlite zlib-dev && \
  rm -rf /var/cache/apk/*

# Install ruby gems.
RUN \
  cd /tmp && \
  git clone https://github.com/tenstartups/backup.git && \
  cd backup && \
  git checkout package_with_storage_id && \
  gem build backup.gemspec && \
  gem install backup -- --use-system-libraries

# Define working directory.
WORKDIR /home/backups

# Define mountable directories.
VOLUME ["/home/backups", "/etc/backups", "/var/lib/backups", "/var/log/backups"]

# Add files to the container.
COPY entrypoint.sh /docker-entrypoint
COPY perform-backup.sh /usr/local/bin/perform-backup

# Set the entrypoint script.
ENTRYPOINT ["/docker-entrypoint"]
