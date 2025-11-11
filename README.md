# Fantasia Gamejam 2025

## Commands

Build the docker server (removes existing container and image, rebuilds, and runs):

```bash
docker stop fantasia-game-server 2>/dev/null || true \
  && docker rm fantasia-game-server 2>/dev/null || true \
  && docker rmi fantasia-server 2>/dev/null || true \
  && docker build -t fantasia-server . \
  && docker run -d -p 9999:9999/udp --name fantasia-game-server fantasia-server \
  && docker logs -f fantasia-game-server
```