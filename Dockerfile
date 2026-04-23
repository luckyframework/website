FROM crystallang/crystal:1.16.3
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
WORKDIR /data
EXPOSE 3001
EXPOSE 5000

RUN apt-get update && \
  apt-get install -y libnss3 libgconf-2-4 chromium-browser curl unzip libreadline-dev golang-go postgresql postgresql-contrib locales && \
  # Install Bun
  curl -fsSL https://bun.sh/install | bash && \
  ln -s /root/.bun/bin/bun /usr/local/bin/bun && \
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

# Install JS dependencies
COPY package.json bun.lock* ./
RUN bun install

COPY . /data
