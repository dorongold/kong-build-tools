set -e

if docker image inspect $KONG_TEST_IMAGE_NAME; then exit 0; fi

if [ "$RESTY_IMAGE_BASE" == "ubuntu" ] || [ "$RESTY_IMAGE_BASE" == "debian" ]; then
  cp output/*${RESTY_IMAGE_TAG}.amd64.deb docker-kong/ubuntu/kong.deb
  BUILD_DIR="ubuntu"
elif [ "$RESTY_IMAGE_BASE" == "alpine" ]; then
  cp output/*.amd64.apk.tar.gz docker-kong/alpine/kong.tar.gz
  BUILD_DIR="alpine"
elif [ "$RESTY_IMAGE_BASE" == "centos" ] || [ "$RESTY_IMAGE_BASE" == "amazonlinux" ]; then
  cp output/*.amd64.rpm docker-kong/centos/kong.rpm
  BUILD_DIR="centos"
fi

if [ "$RESTY_IMAGE_BASE" == "rhel" ]; then
  sed -i 's/^FROM .*/FROM registry.access.redhat.com\/ubi'${RESTY_IMAGE_TAG}'\/ubi/' docker-kong/rhel/Dockerfile
  sed -i 's/rhel7/rhel'${RESTY_IMAGE_TAG}'/' docker-kong/rhel/Dockerfile
  cp output/*.rhel${RESTY_IMAGE_TAG}.amd64.rpm docker-kong/rhel/kong.rpm
  BUILD_DIR="rhel"
else
  sed -i 's/^FROM .*/FROM '${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}'/' docker-kong/${BUILD_DIR}/Dockerfile
fi

pushd docker-kong/${BUILD_DIR}
    docker build -t $KONG_TEST_IMAGE_NAME \
    --no-cache \
    --build-arg ASSET=local .
popd

