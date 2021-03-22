# Phoenix-RTOS docker images

These images are intended to be used when developing Phoenix-RTOS OS and apps.
Prebuilt images are available on [DockerHub](https://hub.docker.com/r/phoenixrtos/build).

## Image types

### phoenixrtos/build

Image with toolchains for `arm7v-a`, `armv7-m`, `ia32` and `riscv` targets.

## Manual build and upload

```bash
DOCKER_BUILDKIT=1 docker build . -t phoenixrtos/build
# building will take about 1 hour - after that test if it builds all TARGETs from phoenix-rtos-project
docker tag phoenixrtos/build:latest phoenixrtos/build:20201019  # use current date
docker push phoenixrtos/build
```

