FROM postgres:10.9

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Bryan Laipple <https://github.com/bryan-laipple>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/bryan-laipple/docker-postgres" \
      org.label-schema.vcs-ref=$VCS_REF

# borrowed from
# https://github.com/debezium/docker-images/blob/master/postgres/10/Dockerfile
# https://github.com/clkao/docker-postgres-plv8/blob/master/10-2/Dockerfile

# Attempting to closely match RDS Postgres 10.9 (neither plv8 or wal2json are noted to have changed since 10.6)
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html
ENV WAL2JSON_COMMIT_ID=9e962bad61ef2bfa53747470bac4d465e71df880 \
    PLV8_VERSION=2.1.2 \
    PLV8_VERSION_TAG=v2.1.2 \
# Remove some things from the build that we don't need from v8 or plv8
    GYP_CHROMIUM_NO_ACTION=0 \
    DEPOT_TOOLS_WIN_TOOLCHAIN=0 \
    DISABLE_DIALECT=1 \
# location of static object files
    PG_LIB=/usr/lib/postgresql/${PG_MAJOR}/lib

# build dependencies
RUN BUILD_DEPS=" \
      build-essential \
      ca-certificates \
      git \
      curl \
      pkg-config \
      postgresql-server-dev-$PG_MAJOR \
      python \
    " \
    && apt-get update \
    && apt-get install -f -y --no-install-recommends ${BUILD_DEPS} \
# wal2json plugin
    && cd / \
    && git clone https://github.com/eulerto/wal2json -b master --single-branch \
    && cd /wal2json \
    && git checkout $WAL2JSON_COMMIT_ID \
    && make && make install \
    && strip ${PG_LIB}/wal2json.so \
# plv8 extension
    && cd / \
    && git clone -b $PLV8_VERSION_TAG --depth 1 https://github.com/plv8/plv8.git \
    && cd /plv8 \
    && make PLV8_VERSION=$PLV8_VERSION static \
    && make PLV8_VERSION=$PLV8_VERSION install \
    && strip ${PG_LIB}/plv8.so \
# cleanup
    && cd / \
    && rm -rf /wal2json /plv8 /var/lib/apt/lists/* \
    && apt-get remove -y ${BUILD_DEPS} \
    && apt-get autoremove -y \
    && apt-get clean
