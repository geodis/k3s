#!/bin/bash
echo "Terraform container"
echo
current_md5=$(md5sum Dockerfile | cut -d " " -f1)

if [ ! -f dockerfile_checksum ] || [ "$(cat dockerfile_checksum)" != "$current_md5" ]
then
    echo "Building"
    echo $current_md5 > dockerfile_checksum
    DOCKER_BUILDKIT=1 docker build \
    --build-arg TARGETPLATFORM="linux/amd64" \
    --build-arg USER=$(whoami) \
    --build-arg USER_ID=$(id -u) \
    --build-arg GROUP=$(id -g) \
    -t k3s:latest \
    -f Dockerfile .
fi

echo "Running ..."
echo
docker run --network host -it --rm \
-v $(pwd)/kube/:$HOME/.kube \
-v $(pwd):/app \
-w /app \
-e KUBECONFIG=$HOME/.kube/kubeconfig \
k3s:latest
