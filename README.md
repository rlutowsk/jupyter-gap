# jupyter-gap

The project aims in building a [docker](https://docker.com) container of [GAP](https://gap-system.org) together with [Jupyter Notebook](https://jupyter.org).

At the current stage of development a GAP package [JupyterKernel](https://gap-packages.github.io/JupyterKernel) the code is nicely colored with notebook version 6, which is included in the application.

## Use of docker compose

An easy way of running the container is to invoke
```bash
docker compose up
```
from inside the folder which contains the `docker-compose.yml` file.

If one uses the `-d` switch, the container app will run in the background. Use the command
```bash
docker compose logs
```
to see the authentication token.

Before using the `docker-compose.yml` file, one should note the following:

1. Volumes are not necessar, but in case one would like to have access to the files then the proper path should be placed in `docker-compose.yml` file.
1. If volumes are unnecessary, then user may be safely deleted from the file.

## CLI version of GAP

After start of the container one can invoke command
```shell
docker exec -u gap -it gap gap
```
to work with GAP in the console.
