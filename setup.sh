#!/usr/bin/env bash

set -e

lpass show 8953247532597087321 --notes | grep POSTGRES > postgres.env
lpass show 8953247532597087321 --notes | grep CONCOURSE > concourse.env

PSQL_DB=$(lpass show 8953247532597087321 --notes | grep POSTGRES_DB | awk -F '=' '{print $2}')
PSQL_USER=$(lpass show 8953247532597087321 --notes | grep POSTGRES_USER | awk -F '=' '{print $2}')
PSQL_PASSWORD=$(lpass show 8953247532597087321 --notes | grep POSTGRES_PASSWORD | awk -F '=' '{print $2}')

export POSTGRES_DB=${PSQL_DB}
export POSTGRES_USER=${PSQL_USER}
export POSTGRES_PASSWORD=${PSQL_PASSWORD}

mkdir -p keys/web keys/worker

yes | ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''
yes | ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''

yes | ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''

cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
cp ./keys/web/tsa_host_key.pub ./keys/worker

docker-machine create --driver virtualbox manager1 || true

for i in {1..3}
do
  docker-machine create --driver virtualbox worker$i || true
done

eval "$(docker-machine env manager1)"

HOST_IP=$(docker-machine env manager1 | grep HOST | awk -F '//' '{print $2}' | awk -F ':' '{print $1}' )
TOKEN_MANAGER=$(docker-machine ssh manager1 docker swarm join-token manager | grep token | awk '{print $2}')
TOKEN_WORKER=$(docker-machine ssh manager1 docker swarm join-token worker | grep token | awk '{print $2}')

export MANAGER_IP=${HOST_IP}
export JOIN_TOKEN_MANAGER=${TOKEN_MANAGER}
export JOIN_TOKEN_WORKER=${TOKEN_WORKER}

export CONCOURSE_EXTERNAL_URL=${MANAGER_IP}:8000

docker-machine ssh manager1 docker swarm init --advertise-addr "${MANAGER_IP}" || true

docker-machine ssh manager1 docker swarm join --token "${JOIN_TOKEN_MANAGER}" "${MANAGER_IP}":2377 || true

for i in {1..3}
do
  docker-machine ssh worker$i docker swarm join --token "${JOIN_TOKEN_WORKER}" "${MANAGER_IP}":2377 || true
done

docker-machine ssh manager1 docker run --name=portainer -d -p 9000:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer || true

docker-machine ssh manager1 docker run --name=visualizer -d -p 5000:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer || true

echo "open visualizer at http://${MANAGER_IP}:5000"

docker stack deploy --compose-file docker-compose.yml cibox

docker service scale cibox_concourse-worker=2
