#!/usr/bin/env bash

set -e

function run_setup() {
  lpass show 186280693047662128 --notes | grep ^POSTGRES > .postgres.env
  lpass show 186280693047662128 --notes | grep ^CONCOURSE > .concourse.env

  PSQL_DB=$(lpass show 186280693047662128 --notes | grep ^POSTGRES_DB | awk -F '=' '{print $2}')
  PSQL_USER=$(lpass show 186280693047662128 --notes | grep ^POSTGRES_USER | awk -F '=' '{print $2}')
  PSQL_PASSWORD=$(lpass show 186280693047662128 --notes | grep ^POSTGRES_PASSWORD | awk -F '=' '{print $2}')

  export POSTGRES_DB=${PSQL_DB}
  export POSTGRES_USER=${PSQL_USER}
  export POSTGRES_PASSWORD=${PSQL_PASSWORD}
}

function main() {
  run_setup
}

main
