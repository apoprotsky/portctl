`portctl` (`Port`ainer `C`on`t`ro`l`) is a command line interface client for managing resources in Portainer

# Features

List objects:
- [x] Portainer endpoints
- [x] Docker Swarm secrets
- [x] Docker Swarm configs
- [ ] Docker Swarm stacks

Create objects:
- [x] Docker Swarm secrets
- [x] Docker Swarm configs
- [ ] Docker Swarm stacks

Update objects:
- [ ] Docker Swarm stacks

Delete objects:
- [ ] Docker Swarm secrets
- [ ] Docker Swarm configs
- [ ] Docker Swarm stacks

Other:
- [x] Render templates for Docker Swarm secrets and configs using environment variables or Hashicorp Vault KV secrets
- [x] Postfix based on data is added to Docker Swarm secrets and configs names

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

