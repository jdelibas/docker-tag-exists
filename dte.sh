#!/bin/bash
# v0.1.0
# Description

# Exit on any failed command
set -e

###
### Dependency checks
###
checkDependencies() {
  for CMD in $@
  do
    command -v $CMD >/dev/null 2>&1 || { echo >&2 "$CMD required but not installed.  Aborting."; exit 1; }
  done
}

# Check if deps are present on system, if not fail build
checkDependencies docker curl jq tr


###
### Variables
###
REGISTRY="registry.hub.docker.com"


###
### Auth
###
DOCKER_AUTH_TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_USER}'", "password": "'${DOCKER_PASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)


###
### Query and check
###
TAGS=$(curl -s -H "Authorization: JWT ${DOCKER_AUTH_TOKEN}" https://hub.docker.com/v2/repositories/$REPOSITORY/tags/?page_size-10000 |  jq -r '.results|.[]|.name')
TAGS_ARRAY=($(echo ${TAGS} | tr " " "\n"))

for i in "${TAGS_ARRAY[@]}"
do
  if [ "$i" == "${TAG}" ] ; then
    echo "${REPOSITORY}:${TAG} exists in ${REGISTRY}"
    exit 1
  fi
done

echo "${REPOSITORY}:${TAG} not found in ${REGISTRY}"