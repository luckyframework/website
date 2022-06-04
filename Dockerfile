FROM crystallang/crystal:1.4.1
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
WORKDIR /data
EXPOSE 3001
EXPOSE 5000

RUN apt-get update && \
  apt-get install -y libnss3 libgconf-2-4 chromium-browser curl libreadline-dev golang-go postgresql postgresql-contrib locales && \
  # Set up node and yarn
  curl --silent --location https://deb.nodesource.com/setup_11.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g yarn && \
  # Lucky cli
  git clone https://github.com/luckyframework/lucky_cli --branch main --depth 1 /usr/local/lucky_cli && \
  cd /usr/local/lucky_cli && \
  shards install && \
  crystal build src/lucky.cr -o /usr/local/bin/lucky && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8

# Install shards
COPY shard.* ./
RUN shards install

# Install node_modules
COPY package.json .
RUN yarn install

COPY . /data
