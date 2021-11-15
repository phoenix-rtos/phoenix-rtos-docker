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
docker run --rm --privileged multiarch/qemu-user-static --reset always -p yes
# change defualt buildx container
docker buildx create --name multiarch --driver docker-container --use
docker buildx inspect --bootstrap

# building will take about approximately 10 hours for arm/v7 and 2 hours for amd64 - after that test if it builds all TARGETs from phoenix-rtos-project
# use --load flag to load image into docker but it works only for one platform
docker buildx build --load --platform linux/arm/v7 -t phoenixrtos/build:armv7 -f build/Dockerfile .
docker buildx build --load --platform linux/amd64 -t phoenixrtos/build:amd64 -f build/Dockerfile .

# push images to the docker hub repo
docker push phoenixrtos/build:armv7
docker push phoenixrtos/build:amd64

# create manifest composed of images of different architectures
docker manifest create phoenixrtos/build:latest phoenixrtos/build:armv7 phoenixrtos/build:amd64
# push the image
docker manifest push phoenixrtos/build:latest

# create the same manifest with the current date
docker manifest create phoenixrtos/build:2021116 phoenixrtos/build:armv7 phoenixrtos/build:amd64
docker manifest push phoenixrtos/build:2021116

