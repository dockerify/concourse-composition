#!/usr/bin/env bash

set -ex

lpass show 8953247532597087321 --notes | grep POSTGRES > .postgres-env
lpass show 8953247532597087321 --notes | grep CONCOURSE > .concourse-env

mkdir -p keys/web keys/worker

ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''
ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''

ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''

cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
cp ./keys/web/tsa_host_key.pub ./keys/worker

docker-compose up
