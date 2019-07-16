# dns

> [Unbound](https://nlnetlabs.nl/projects/unbound/about/) based Docker container.

```
$ docker cp [container_id]:/usr/local/etc/unbound unbound
```

```
$ docker run --volume unbound:/usr/local/etc/unbound dns
```

## Usage

```
$ docker-compose up
```

### Notes

- pid file is probably not required for a container instance... add `-p` option
  to your command

- doubt this is required for a dev env
    - `$ unbound-control-setup`
