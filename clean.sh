#!/usr/bin/env bash

set -e

function run_clean() {
  rm .concourse.env
  rm .postgres.env
}

function main() {
  run_clean
}

main
