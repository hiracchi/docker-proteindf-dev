#!/bin/bash

PACKAGE=hiracchi/proteindf-dev
TAG=latest
CONTAINER_NAME=proteindf-dev

docker run \
       --name ${CONTAINER_NAME} \
       --publish "8888:8888" \
       --volume "${PWD}:/work" \
       --volume "${PWD}/opt:/opt" \
       "${PACKAGE}:${TAG}" \
