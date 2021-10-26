# Phoenix-RTOS docker images

These images are intended to be used when developing Phoenix-RTOS OS and apps.
Prebuilt images are available on [DockerHub](https://hub.docker.com/r/phoenixrtos/build).

## Image types

### phoenixrtos/build

Image with toolchains for `arm7v-a`, `armv7-m`, `ia32` and `riscv` targets.

### phoenixrtos/devel

Based on `phoenixrtos/build` - additional development tools added.

## Manual build and upload

```bash
# additional steps may be needed for building image - check builders using command docker buildx ls
# run container with all archs
docker run --rm --privileged multiarch/qemu-user-static -p yes
# change defualt buildx container
docker buildx create --name multiarch --driver docker-container --use
docker buildx inspect --bootstrap

# building will take about approximately 10 hours - after that test if it builds all TARGETs from phoenix-rtos-project
# use --load flag to load image into docker but it works only for one platform
# use --push to push multi-platform image into registry use
docker buildx build --platform linux/arm/v7,linux/amd64 --push -t phoenixrtos/build:latest -f build/Dockerfile .

# additionaly push the image one more time tagged with the current date
docker buildx build --platform linux/arm/v7,linux/amd64 --push -t phoenixrtos/build:20211126 -f build/Dockerfile .
```

