FROM golang:1.22.1 AS builder

ARG MIGRATE_DB_SUPPORT
ARG MIGRATE_TAG

RUN apt update
RUN apt install -y git ca-certificates
RUN mkdir -p /migrate-build

# If MIGRATE_TAG is provided, clone the repository with the specified tag
RUN if [ -n "$MIGRATE_TAG" ]; then \
        git clone --branch $MIGRATE_TAG https://github.com/golang-migrate/migrate.git /migrate-build; \
    else \
        git clone https://github.com/golang-migrate/migrate.git /migrate-build; \
    fi

WORKDIR /migrate-build

# if MIGRATE_DB_SUPPORT is provided, build using that - otherwise, build default
RUN if [ ! -z "$MIGRATE_DB_SUPPORT" ]; then \
      DATABASE="$MIGRATE_DB_SUPPORT" make build; \
    else \
      make build; \
    fi

# Shrink
FROM busybox
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /migrate-build/migrate /usr/local/bin/migrate
RUN ln -s /usr/local/bin/migrate /migrate

ENTRYPOINT ["migrate"]
CMD ["--help"]
