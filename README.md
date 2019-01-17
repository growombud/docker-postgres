# docker-postgres
Dockerized PostgreSQL server with some goodies; specifically the plv8 extension and wal2json plugin.

## Configuration
As recommended by the official [postgres docker image docs](https://hub.docker.com/_/postgres/),
secrets are passed to the container through `_FILE` environment variables. A default
database, superuser name and password will be set based on the contents of the
`./pg_db`, `./pg_user` and `./pg_pwd` files located in the project root directory. These need
to be created and populated with the desired authentication information.

## Running
```docker-compose up --detach```

