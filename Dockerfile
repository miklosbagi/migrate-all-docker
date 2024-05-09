FROM golang:1.22.1 AS builder

ARG MIGRATE_DB_SUPPORT="sqlite3 postgres"
ARG MIGRATE_TAG="v4.17.1"

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
      CGO_ENABLED=1 \
      go build \
        -ldflags "-X main.Version=$(git describe --tags 2>/dev/null | cut -c 2-)" \
        -tags "$MIGRATE_DB_SUPPORT $(grep ^SOURCE Makefile|sed 's#.*= ##')" \
      ./cmd/migrate; \
    else \
      make build; \
    fi


# Shrink
FROM busybox:1.36.1
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /migrate-build/migrate /usr/local/bin/migrate
RUN ln -s /usr/local/bin/migrate /migrate

ENTRYPOINT ["migrate"]
CMD ["--help"]
