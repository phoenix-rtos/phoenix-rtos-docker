# Phoenix-RTOS docker images

These images are intended to be used when developing Phoenix-RTOS OS and apps.
Prebuilt images are available on [DockerHub](https://hub.docker.com/r/phoenixrtos/build).

## Image types

### phoenixrtos/build

Image with toolchains for `arm7v-a/r`, `armv7-m`, `armv8m`, `armv8r`,
`aarch64`, `ia32`, `riscv` and `sparc` targets.

### phoenixrtos/devel

Based on `phoenixrtos/build` - additional development tools added.

## Manual build and upload

### NOTE

Any new changes must be tested on all supported target architectures before merging the PR with Dockerfile changes in phoenix-rtos-docker! 

### multiarch images

gh-runner

```bash
# additional steps may be needed for building image - check builders using command docker buildx ls
# run container with all archs
docker run --rm --privileged tonistiigi/binfmt --install all
# change default buildx container
docker buildx create --name multiarch --driver docker-container --use
docker buildx inspect --bootstrap

IMAGE_NAME=gh-runner
DATE=$(date +%Y%m%d) # or v3.2.1 ( DATE=$PHOENIX_PROJECT_REF )
PHOENIX_PROJECT_REF="HEAD" # set explicit phoenix-rtos-project commit id/tag

# if building release (not based on phoenixrtos/build:latest) use --build-arg BASE_IMAGE_VERSION=$PHOENIX_PROJECT_REF
# use --load flag to load image into docker but it works only for one platform
docker buildx build --load --progress=plain --platform linux/amd64 --build-arg PHOENIX_PROJECT_REF=$PHOENIX_PROJECT_REF -t phoenixrtos/$IMAGE_NAME:amd64 -f $IMAGE_NAME/Dockerfile $IMAGE_NAME
docker buildx build --load --progress=plain --platform linux/arm64 --build-arg PHOENIX_PROJECT_REF=$PHOENIX_PROJECT_REF -t phoenixrtos/$IMAGE_NAME:arm64 -f $IMAGE_NAME/Dockerfile $IMAGE_NAME
 
# push images to the DockerHub repo #
docker push phoenixrtos/$IMAGE_NAME:amd64
docker push phoenixrtos/$IMAGE_NAME:arm64

# create manifest composed of images of different architectures
# WARN: only remote images are taken into account, -amend doesn't really work
docker manifest rm phoenixrtos/$IMAGE_NAME
docker manifest create phoenixrtos/$IMAGE_NAME:latest phoenixrtos/$IMAGE_NAME:amd64 phoenixrtos/$IMAGE_NAME:arm64

# push the image
docker manifest push phoenixrtos/$IMAGE_NAME:latest

# create the same manifest with the current date
docker manifest create phoenixrtos/$IMAGE_NAME:$DATE phoenixrtos/$IMAGE_NAME:amd64 phoenixrtos/$IMAGE_NAME:arm64
docker manifest push phoenixrtos/$IMAGE_NAME:$DATE

### push images to the Github Registry ###
docker image tag phoenixrtos/$IMAGE_NAME:amd64 ghcr.io/phoenix-rtos/$IMAGE_NAME:amd64
docker push ghcr.io/phoenix-rtos/$IMAGE_NAME:amd64
docker image tag phoenixrtos/$IMAGE_NAME:arm64 ghcr.io/phoenix-rtos/$IMAGE_NAME:arm64
docker push ghcr.io/phoenix-rtos/$IMAGE_NAME:arm64

# WARN: only remote images are taken into account, -amend doesn't really work
docker manifest rm ghcr.io/phoenix-rtos/$IMAGE_NAME
docker manifest create ghcr.io/phoenix-rtos/$IMAGE_NAME:latest ghcr.io/phoenix-rtos/$IMAGE_NAME:arm64 ghcr.io/phoenix-rtos/$IMAGE_NAME:amd64
# push the image
docker manifest push ghcr.io/phoenix-rtos/$IMAGE_NAME:latest

# for now don't push version-tagged manifests to ghcr.io

# create new tag in the repo
git tag -a $DATE -m "release: $DATE"
```

### amd64 images

build, devel

```bash
IMAGE_NAME=build
DATE=$(date +%Y%m%d) # or v3.2.1 ( DATE=$PHOENIX_PROJECT_REF )
PHOENIX_PROJECT_REF="HEAD" # set explicit phoenix-rtos-project commit id/tag

# building will take about approximately 2 hours - after that test if it builds all TARGETs from phoenix-rtos-project
# use --load flag to load image into docker but it works only for one platform
# if building release (not based on phoenixrtos/build:latest) use --build-arg BASE_IMAGE_VERSION=$PHOENIX_PROJECT_REF
docker buildx build --load --progress=plain --platform linux/amd64 --build-arg PHOENIX_PROJECT_REF=$PHOENIX_PROJECT_REF -t phoenixrtos/$IMAGE_NAME:amd64 -f $IMAGE_NAME/Dockerfile $IMAGE_NAME

# re-tag image as latest/date
docker image tag phoenixrtos/$IMAGE_NAME:amd64 phoenixrtos/$IMAGE_NAME:latest
docker image tag phoenixrtos/$IMAGE_NAME:amd64 phoenixrtos/$IMAGE_NAME:$DATE

### test if docker-build.sh works ###
 
### push images to the DockerHub repo ###
docker push phoenixrtos/$IMAGE_NAME:amd64
docker push phoenixrtos/$IMAGE_NAME:$DATE
docker push phoenixrtos/$IMAGE_NAME:latest

### push images to the Github Registry ###
docker image tag phoenixrtos/$IMAGE_NAME:amd64 ghcr.io/phoenix-rtos/$IMAGE_NAME:amd64
docker image tag ghcr.io/phoenix-rtos/$IMAGE_NAME:amd64 ghcr.io/phoenix-rtos/$IMAGE_NAME:latest

# push to remote
docker push ghcr.io/phoenix-rtos/$IMAGE_NAME:amd64
docker push ghcr.io/phoenix-rtos/$IMAGE_NAME:latest

# if release (v3.2.1) push to ghcr.io also
docker image tag ghcr.io/phoenix-rtos/$IMAGE_NAME:amd64 ghcr.io/phoenix-rtos/$IMAGE_NAME:$DATE
docker push ghcr.io/phoenix-rtos/$IMAGE_NAME:$DATE

# create new tag in the repo
git tag -a $DATE -m "release: $DATE"
```
