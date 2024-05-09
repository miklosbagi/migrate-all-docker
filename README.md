# migrate-all-docker
Migrate with variations for db support, dockerfile.  

## Build time options
The following options are available to use for the docker build command:  
- MIGRATE_DB_SUPPORT is an optional (but recommended) option for building is a list of DBs to be supported by the migrate binary after build. Examples here [from Makefile (date stamp: 2024-05-08)](https://github.com/golang-migrate/migrate/blob/5163ac782428cddbc7feba4a19fe94f9ae925699/Makefile#L2-L3). Skipping this param is possible, but makes this Dockerfile useless, as it will build migrate exactly as it is in their repo :)
- MIGRATE_TAG: is an optional variable to stick to a specific tag, instead of bulding based on master. 

## Multi-architecture (amd+arm) build example on apple silicon
```
  MIGRATE_DB_SUPPORT="postgres mysql redshift cassandra spanner \
                      cockroachdb yugabytedb clickhouse mongodb \
                      sqlserver firebird neo4j pgx pgx5 rqlite \
                      sqlite sqlite3 sqlcipher"
  MIGRATE_TAG="v4.17.1"

  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg "MIGRADE_DB_SUPPORT=$MIGRATE_DB_SUPPORT" \
    --build-arg "MIGRATE_TAG=$MIGRATE_TAG" \
    -t my-migrate:all-latest
```

## Docker hub
`docker pull miklosbagi/migrate-postgres-sqlite3`
