#!/bin/sh

# shellcheck disable=SC1091
. ./utils.sh || exit 1

_test_executable "docker" || exit 1

mkdir -p "${HOME}/.docker/completions"
docker completion zsh > "${HOME}/.docker/completion_docker"

# if docker info is not work, we are likely runnign Docker Desktop
if ! docker info >/dev/null 2>&1; then
    open -a Docker || return 1
    # Wait until the Docker daemon is up
    printf "Waiting for Docker daemon to start"
    while ! docker info >/dev/null 2>&1; do
        printf "."
        sleep 2
    done
fi

docker pull jbarlow83/ocrmypdf-alpine