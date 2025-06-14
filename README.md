# Porkbun SSL Certificate Fetcher

Utility to fetch
[wildcard LetsEncrypt SSL certificates from Porkbun-registered domains](https://porkbun.com/products/ssl)
using their API.

If the certificates already exist on disk they are not overwritten, enabling downstream tools to check the file modtime
to determine when to reload.

## Usage

```
porkbun-cert-fetch [--destination DIR] [--force] [--node_exporter_textfile_dir DIR] domain ...
```

You will need to enable Porkbun API access for the domain(s) you intend to query, and then provide the API and secret
keys via the environment variables `API_KEY` and `SECRET_API_KEY`, respectively.

* `--destination`                 Specify the directory to write the certificates to, defaults to ~/.ssl
* `--force`                       Overwrite local files even if the contents have not changed
* `--node_exporter_textfile_dir`  Specify a directory to write Prometheus metrics to, for publishing via node_exporter

## Docker Compose

Although the utility can be run directly and has minimal dependencies (`curl`, `jq`), it can be convenient to run inside
a container or with Docker Compose.
A [container is provided with this repository](http://ghcr.io/dimo414/porkbun-cert-fetch), but it's particularly
convenient to use Docker Compose to specify the configuration you'd like to run. For example:

```
services:
  porkbun-cert-fetch:
    image: ghcr.io/dimo414/porkbun-cert-fetch:main
    container_name: porkbun-cert-fetch
    user: 1000:1000  # set this to write the files as a non-root owner
    environment:
      API_KEY: [API KEY]
      SECRET_API_KEY: [SECRET API KEY]
      NODE_EXPORTER_TEXTFILE_DIR: /var/lib/node_exporter/textfile_collector
    command:
      - '--destination'
      - '/ssl'
      - 'yourdomain.com'
      - 'anotherdomain.dev'
    volumes:
      - '~/.ssl:/ssl'
      - '/var/lib/node_exporter/textfile_collector:/var/lib/node_exporter/textfile_collector'
```

This writes the certificate files to `~/.ssl` on the host (mounted as `/ssl` in the container) as the specified user.
Use `id -u` and `id -g` to see your UID/GID assuming that is the user you'd like to run as.

The `NODE_EXPORTER_TEXTFILE_DIR` variable and `/var/lib/node_exporter/textfile_collector` mount are optional, and only
needed if you want to monitor this script with Prometheus.

This is intended to be executed with [`docker compose run`](https://docs.docker.com/reference/cli/docker/compose/run/)
via `cron`. There are other ways to schedule Docker tasks, such as [Ofelia](https://hub.docker.com/r/mcuadros/ofelia),
however for simple tasks like this cron is likely sufficient.

```
# Fetch LetsEncrypt SSL certs from Porkbun
2 30 1,15 * * docker compose --project-directory /path/to run --rm porkbun-cert-fetch
```

You can also use [`task-mon`](https://github.com/dimo414/task-mon) to monitor the run with healthchecks.io:

```
# Fetch LetsEncrypt SSL certs from Porkbun
2 30 1,15 * * /usr/local/bin/task-mon --uuid [...] --detailed -- docker compose --project-directory /path/to run --rm porkbun-cert-fetch
```

# Credits

Thanks to https://github.com/corey-braun/porkbun-api-bash for the idea / inspiration. All code in this repository is my
own, but it was a helpful reference.