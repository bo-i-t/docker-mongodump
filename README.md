# Docker Mongodump

Easily automate MongoDB backups.

Intended to facilitate fast setup of automated MongoDB backups by combining [bo-i-t/docker-cron](https://github.com/bo-i-t/docker-cron)
and [mongodump](https://www.mongodb.com/docs/database-tools/mongodump/).

## Quickstart

For illustration purposes, the example in [docker-compose.yml](./docker-compose.yml) will be used.

**Note that this configuration should not be used in production.**

The examples services are startet via
```
docker compose up -d
```

The `mongo-backup` service will execute the cron schedule specified in [example-cronfile](./example-cronfile), as it is mounted at `/etc/cron.d/crontab`.
This causes the [dump.sh](./dump.sh) script to be executed every minute. The script wraps `mongodump` and will save its output to `/backups/` inside
the container. Note in the compose file, that the host directory `/tmp/example-mongodump/` is mounted to this location, such that dumps can be easily accessed,
e.g. to be moved to another machine.

Have a look at the logs of the backup service:
```
docker compose logs -f mongo-backup
```

Stop the example services via
```
docker compose down
```

## Details

### Mongodump configuration

The basic idea of this image is to have a dedicated service with a single responsibility: To create regular dumps of databases in one (fixed) mongo instance.
This instance is configured by passing the `MONGO_HOST` and `MONGO_PORT` environment variables to the container. The variables `MONGO_USERNAME`, `MONGO_PASSWORD` and `MONGO_AUTHENTICAION_DATABASE` specify how `mongodump` should authenticate when connecting to the mongo instance. Note that, in constrast to the quickstart example above,
the backup service should usually not use root credentials for this, but instead a dedicated backup account (see MongoDB Docs [here](https://www.mongodb.com/docs/manual/reference/built-in-roles/#mongodb-authrole-backup)).  
Finally, the variable `MONGO_DB` can be used to specify a single database to dump. Alternatively, the [dump.sh](./dump.sh) script will use it's first command line
argument over this environment variable to determine the db to be backed up. If the value is empty, all databases will be dumped.

Note hat these `MONGO_*` environment variables are mapped to the corresponding [mongodump command line flags](https://www.mongodb.com/docs/database-tools/mongodump/#options) `--*`.

### Cron configuration

Cron jobs are configured by placing a cronfile at `/etc/cron.d/crontab` in the container, e.g. by mounting as in the quickstart example above. For more details, please refer to the base image [bo-i-t/docker-cron](https://github.com/bo-i-t/docker-cron).

As described in the previous section, the provided dump script accepts the database to be dumped as a command line argument. So, if multiple databases should be backed up with different frequencies, this could be realized with a cron file like this: 
```
0 0 * * * /usr/bin/dump.sh db1 >> /var/log/cron.log 2>&1
0 0 * * 1 /usr/bin/dump.sh db2 >> /var/log/cron.log 2>&1
```
In this case `db1` would be backed up every day at midnight, while `db2` is only backed up once a week.

Of course one does not have to use the provided `/usr/bin/dump.sh` scripts in the cron file. E.g. if more flexibility is required, `mongodump` could be used directly in the cron file or in custom scripts.

### Manual execution

For additional manual backups next to the cron schedule one can call `dump.sh` or `mongodump` directly on the container. E.g. in the quickstart example one could manually backup the `admin` db (specified in the `MONGO_DB` environment variable) via
```
docker compose exec mongo-backup dump.sh
```
Any other `<DB>` could be manually backed up via
```
docker compose exec mongo-backup dump.sh <DB>
```