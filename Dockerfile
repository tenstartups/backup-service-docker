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
  BACKUP_DATA_DIR=/var/lib/backups

# Install base packages.
RUN \
  echo 'http://dl-4.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories && \
  apk --update add build-base git libxml2-dev libxslt-dev mysql-client postgresql \
               redis ruby ruby-bigdecimal ruby-bundler ruby-dev ruby-irb \
               ruby-io-console ruby-json ruby-nokogiri sqlite zlib-dev && \
  rm -rf /var/cache/apk/*

# Install ruby gems.
RUN \
  cd /tmp && \
  git clone https://github.com/tenstartups/backup.git && \
  cd backup && \
  git checkout package_with_storage_id && \
  gem build backup.gemspec && \
  gem install backup --no-document -- --use-system-libraries && \
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
