`portctl` (`Port`ainer `C`on`t`ro`l`) is a command line interface tool for managing resources in `Portainer`

# How to use

Let's deploy standalone `RabbitMQ` as stack in `Docker Swarm`

Start environment using `Docker` or `Podman`:
```sh
docker run -it --rm --name portctl apoprotsky/portctl /bin/sh
```

Configure parameters to work with `Portainer API` and `Hashicorp Vault`
```sh
export PORTAINER_API=https://portainer.example.com
export PORTAINER_TOKEN=ptr_U+portainertoken
export VAULT_ADDR=https://vault.example.com
export VAULT_TOKEN=hvs.vaulttoken
export RABBITMQ_VERSION=3.9.8-management-alpine
```

Create template file `rabbitmq.conf` for `Docker Swarm` secret where
`default_pass` will be filed from field `password` of `Hashicorp Vault` secret `kv/rabbitmq`
```ini
default_user = rabbitmq
default_pass = {{ vault:kv/rabbitmq.password }}
default_vhost = /
cluster_formation.peer_discovery_backend = classic_config
cluster_formation.classic_config.nodes.1 = rabbit@server
```

Create template file `stack.env` for `Docker Swarm` stack variables where
`RABBITMQ_VERSION` and `RABBITMQ_CONFIG` will be filled from environment variables and
`RABBITMQ_ERLANG_COOKIE` will be filed from field `cookie` of `Hashicorp Vault` secret `kv/rabbitmq`
```ini
RABBITMQ_VERSION={{ env:RABBITMQ_VERSION }}
RABBITMQ_ERLANG_COOKIE={{ vault:kv/rabbitmq.cookie }}
RABBITMQ_CONFIG={{ env:RABBITMQ_CONFIG }}
```

Prepare `Docker Swarm` stack file `stack.yml`
```yml
version: '3'
services:
  server:
    image: rabbitmq::${RABBITMQ_VERSION}
    environment:
      RABBITMQ_ERLANG_COOKIE: ${RABBITMQ_ERLANG_COOKIE}
    hostname: server
    volumes:
      - rabbitmq:/var/lib/rabbitmq
    secrets:
      - source: rabbitmq.conf
        target: /etc/rabbitmq/rabbitmq.conf
volumes:
  rabbitmq:
secrets:
  rabbitmq.conf:
    external: true
    name: ${RABBITMQ_CONFIG}
```

Get list of available `Portainer` endpoints to choose where to deploy new stack
```sh
portctl endpoints list
export PORTAINER_ENDPOINT=endpoint_name_from_list
```

Deploy `Docker Swarm` secret and save its name to environment variable `RABBITMQ_CONFIG`
```sh
export RABBITMQ_CONFIG=`portctl secrets apply --name rabbitmq.conf --file rabbitmq.conf`
```

Deploy prepared stack
```sh
portctl stacks apply --name rabbitmq --file stack.yml --vars stack.env
```

View list of stacks
```sh
portctl stacks list
```

# Features

Noticeable:
- Render templates for `Docker Swarm` secrets, configs or stack variables file using environment variables or `Hashicorp Vault` KV secrets
- Postfix (`-` followed by five symbols from `base58` string of `md5` hash of data) is adding to `Docker Swarm` secrets and configs names on creation to make them unique
- Apply commands try to delete staled `Docker Swarm` configs and secrets. Configs and secrets consider as staled if its name is not equal current and resource are below first [TaskHistoryRetentionLimit](https://docs.docker.com/engine/reference/commandline/swarm_init/#--task-history-limit) items in list ordered by date.

List:
- `Portainer` endpoints, stacks for `Docker Swarm`
- `Docker Swarm` configs, secrets

Create:
- `Portainer` stacks for `Docker Swarm`
- `Docker Swarm` configs, secrets

Update:
- `Portainer` stacks for `Docker Swarm`

Delete:
- `Portainer` stacks for `Docker Swarm`
- `Docker Swarm` configs, secrets

# Environment for development

For using `make watch` need to install `fswatch` utility

```sh
brew install fswatch
```

# Additional infromation

Portainer API

https://app.swaggerhub.com/apis/portainer/portainer-ce

Docker API

https://docs.docker.com/engine/api/latest

