#!/usr/bin/env bash

set -e

function run_compose() {
  docker-compose up
}

function main() {
  run_compose
}

main
