ARG CRYSTAL_VERSION=1.16.3

# Install Crystal shards (production set)
FROM crystallang/crystal:$CRYSTAL_VERSION AS crystal_dependencies
WORKDIR /shards
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    cmake \
  && rm -rf /var/lib/apt/lists/*
ENV SKIP_LUCKY_TASK_PRECOMPILATION=1
COPY shard.yml shard.lock shard.override.yml ./
RUN shards install --production

# Install JS deps and build production CSS/JS via Bun
FROM oven/bun:1 AS frontend_build
WORKDIR /frontend
COPY package.json bun.lock ./
COPY --from=crystal_dependencies /shards/lib/lucky/src/bun lib/lucky/src/bun
RUN bun install --frozen-lockfile
COPY . .
RUN bun run prod

# Compile the Crystal webserver binary
FROM crystallang/crystal:$CRYSTAL_VERSION AS lucky_binaries_build
WORKDIR /binaries_build
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
  && rm -rf /var/lib/apt/lists/*
ENV LUCKY_ENV=production
COPY . .
COPY --from=crystal_dependencies /shards/lib lib
COPY --from=frontend_build /frontend/public public
RUN shards build --production --release \
  && mv ./bin/website_v2 /usr/local/bin/webserver \
  && chmod +x /usr/local/bin/webserver

# Slim runtime image
FROM ubuntu:24.04 AS webserver
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    ca-certificates \
    curl \
    libevent-dev \
    libpcre2-dev \
    libssl-dev \
    libxml2-dev \
    libyaml-dev \
    tzdata \
    zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /app
ENV LUCKY_ENV=production
ENV PORT=8080
EXPOSE 8080
COPY --from=lucky_binaries_build /usr/local/bin/webserver webserver
COPY --from=frontend_build /frontend/public public
COPY ./config/watch.yml config/
CMD ["./webserver"]
