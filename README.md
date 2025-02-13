# jupyter-gap

## Build with docker buildx

```shell
docker buildx build -t rlutowsk/jupyter-gap .
```

## docker compose

1. Volumes are not necessar, but in case one would like to have access to the files then the proper path should be placed in `docker-compose.yml` file.
1. If volumes are unnecessary, then user may be safely deleted from the file.

## cli

After start of the container one can invoke command
```shell
docker exec -u gap -it gap gap
```
to work with GAP in the console.
