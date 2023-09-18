# Phoenix-RTOS docker images

These images are intended to be used when developing Phoenix-RTOS OS and apps.
Prebuilt images are available on [DockerHub](https://hub.docker.com/r/phoenixrtos/build).

## Image types

### phoenixrtos/build

Image with toolchains for `arm7v-a`, `armv7-m`, `ia32`, `riscv` and `sparc` targets.

### phoenixrtos/devel

Based on `phoenixrtos/build` - additional development tools added.

## Manual build and upload

```bash
# additional steps may be needed for building image - check builders using command docker buildx ls
# run container with all archs
docker run --rm --privileged multiarch/qemu-user-static --reset always -p yes
# change default buildx container
docker buildx create --name multiarch --driver docker-container --use
docker buildx inspect --bootstrap

IMAGE_NAME=build
DATE=$(date +%Y%m%d)

# building will take about approximately 10 hours for arm/v7 and 2 hours for amd64 - after that test if it builds all TARGETs from phoenix-rtos-project
# use --load flag to load image into docker but it works only for one platform
docker buildx build --load --platform linux/arm/v7 -t phoenixrtos/$IMAGE_NAME:armv7 -f $IMAGE_NAME/Dockerfile $IMAGE_NAME
docker buildx build --load --platform linux/amd64 -t phoenixrtos/$IMAGE_NAME:amd64 -f $IMAGE_NAME/Dockerfile $IMAGE_NAME

# push images to the docker hub repo
docker push phoenixrtos/$IMAGE_NAME:armv7
docker push phoenixrtos/$IMAGE_NAME:amd64

# create manifest composed of images of different architectures
# WARN: only remote images are taken into account, -amend doesn't really work
docker manifest rm phoenixrtos/$IMAGE_NAME
docker manifest create phoenixrtos/$IMAGE_NAME:latest phoenixrtos/$IMAGE_NAME:armv7 phoenixrtos/$IMAGE_NAME:amd64
# push the image
docker manifest push phoenixrtos/$IMAGE_NAME:latest

# create the same manifest with the current date
docker manifest create phoenixrtos/$IMAGE_NAME:$DATE phoenixrtos/$IMAGE_NAME:armv7 phoenixrtos/$IMAGE_NAME:amd64
docker manifest push phoenixrtos/$IMAGE_NAME:$DATE

# create new tag in the repo
git tag -a $DATE

```

Repeat the above steps for:

```bash
IMAGE_NAME=devel
IMAGE_NAME=gh-runner
```
