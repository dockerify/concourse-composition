#!/usr/bin/env bash

set -e

function load_creds() {
  lpass show 8953247532597087321 --notes | grep ^POSTGRES > .postgres.env
  lpass show 8953247532597087321 --notes | grep ^CONCOURSE > .concourse.env

  PSQL_DB=$(lpass show 8953247532597087321 --notes | grep POSTGRES_DB | awk -F '=' '{print $2}')
  PSQL_USER=$(lpass show 8953247532597087321 --notes | grep POSTGRES_USER | awk -F '=' '{print $2}')
  PSQL_PASSWORD=$(lpass show 8953247532597087321 --notes | grep POSTGRES_PASSWORD | awk -F '=' '{print $2}')

  export POSTGRES_DB=${PSQL_DB}
  export POSTGRES_USER=${PSQL_USER}
  export POSTGRES_PASSWORD=${PSQL_PASSWORD}
}

function run_keygen() {
  mkdir -p keys/web keys/worker

  yes | ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''
  yes | ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''

  yes | ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''

  cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
  cp ./keys/web/tsa_host_key.pub ./keys/worker
}

function main() {
  load_creds
  run_keygen
}

main
