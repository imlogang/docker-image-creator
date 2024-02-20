FROM --platform=linux/amd64 us-central1-docker.pkg.dev/wandb-production/hub/golang:1.21.7-bullseye

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt update && apt install -y nodejs yarn

# Install the necessary build dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  ca-certificates \
  libssl-dev \
  libffi-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev

# Download and install Python 3.10
RUN curl -SL https://www.python.org/ftp/python/3.10.8/Python-3.10.8.tgz -o python.tgz && \
  tar -xzf python.tgz && \
  cd Python-3.10.8 && \
  ./configure --enable-optimizations && \
  make -j $(nproc) && \
  make altinstall && \
  cd .. && \
  rm -rf Python-3.10.8 python.tgz

# Update the default Python and pip version
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 1 && \
  update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.10 1

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
  echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" > /etc/apt/sources.list.d/docker.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends docker-ce-cli

# Install Docker Buildx
RUN BUILDX_VERSION=v0.10.3 \
  && BUILDX_BINARY_URL=https://github.com/docker/buildx/releases/download/$BUILDX_VERSION/buildx-$BUILDX_VERSION.linux-amd64 \
  && curl -sSL --retry 3 --progress-bar --location --remote-name $BUILDX_BINARY_URL \
  && chmod a+x buildx-$BUILDX_VERSION.linux-amd64 \
  && mkdir -p ~/.docker/cli-plugins \
  && mv buildx-$BUILDX_VERSION.linux-amd64 ~/.docker/cli-plugins/docker-buildx

RUN cd /root && \
  curl -o ./gcloud.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-388.0.0-linux-x86_64.tar.gz && \
  tar -xf gcloud.tar.gz && \
  ./google-cloud-sdk/install.sh -q --path-update true && \
  ln -s /root/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud && \
  ln -s /root/google-cloud-sdk/bin/docker-credential-gcloud /usr/local/bin/docker-credential-gcloud

# COPY --link ./make/requirements.txt /tmp/requirements.txt
# RUN pip install -r /tmp/requirements.txt

# the dagger library will install this client when it's first run. By installing it
# during the build, we save some bandwidth and guard against network interruptions
RUN curl -L https://dl.dagger.io/dagger/install.sh | DAGGER_VERSION=$(grep 'dagger-io==' /tmp/requirements.txt | awk -F '==' '{print $2}') sh

WORKDIR /tmp/core
# COPY --link services/go.* ./services/
# COPY --link go.work* ./
# COPY --link ./services/gorilla/internal/graphql-go ./services/gorilla/internal/graphql-go
# COPY --link ./tools/binlog_reader/go.* ./tools/binlog_reader/
# COPY --link ./tools/governor/go.* ./tools/governor/
# COPY --link ./tools/wandbctl/go.* ./tools/wandbctl/
# RUN cd services && \
#   go mod download
