FROM rust:1.63 as prisma-engines

ENV APP_PATH=/code

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y -q \
    openssl direnv

WORKDIR $APP_PATH

RUN mkdir -p ./build
RUN cd build/ \
    && git clone https://github.com/prisma/prisma-engines --branch=3.13.0

RUN cd build/prisma-engines/ \
    && direnv allow \
    && eval "$(direnv export bash)" \
    && cargo build --release

# main
FROM python:3.8.13

ENV APP_PATH=/code

RUN apt-get update && \
    apt-get install -y dnsutils

WORKDIR /root

COPY ./prisma/set_database_url.sh ./set_database_url.sh
RUN chmod +x set_database_url.sh
RUN echo '. ~/set_database_url.sh' >> ./.bashrc

WORKDIR $APP_PATH

RUN mkdir -p ./bin

COPY --from=prisma-engines $APP_PATH/build/prisma-engines/target/release/prisma-fmt $APP_PATH/bin/prisma-fmt
COPY --from=prisma-engines $APP_PATH/build/prisma-engines/target/release/introspection-engine $APP_PATH/bin/introspection-engine
COPY --from=prisma-engines $APP_PATH/build/prisma-engines/target/release/migration-engine $APP_PATH/bin/migration-engine
COPY --from=prisma-engines $APP_PATH/build/prisma-engines/target/release/query-engine $APP_PATH/bin/query-engine

RUN wget -O prisma-cli-linux.gz https://prisma-photongo.s3-eu-west-1.amazonaws.com/prisma-cli-3.13.0-linux-arm64.gz && \
    gzip -d ./prisma-cli-linux.gz && \
    mv ./prisma-cli-linux ./bin/prisma-cli-linux

RUN chmod +x bin/prisma-fmt
RUN chmod +x bin/introspection-engine
RUN chmod +x bin/migration-engine
RUN chmod +x bin/query-engine
RUN chmod +x bin/prisma-cli-linux

ENV PRISMA_QUERY_ENGINE_BINARY=$APP_PATH/bin/query-engine \
    PRISMA_MIGRATION_ENGINE_BINARY=$APP_PATH/bin/migration-engine \
    PRISMA_INTROSPECTION_ENGINE_BINARY=$APP_PATH/bin/introspection-engine \
    PRISMA_FMT_BINARY=$APP_PATH/bin/prisma-fmt \
    PRISMA_CLI_BINARY=$APP_PATH/bin/prisma-cli-linux \
    PRISMA_BINARY_CACHE_DIR=$APP_PATH/bin/

RUN pip install poetry && \
    poetry config virtualenvs.create false

# poetry
COPY ./pyproject.toml ./poetry.lock ./
RUN poetry install

COPY ./prisma ./prisma
COPY ./src ./src


