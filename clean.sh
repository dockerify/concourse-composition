#!/usr/bin/env bash

set -e

function run_clean() {
  rm .concourse.env
  rm .postgres.env
  rm -rfv keys
}

function main() {
  run_clean
}

main
