#!/bin/bash

version=$(cat .release-version)
retry_limit=10

while [ true ]; do
  status=$(curl -sI https://trellis.getto.systems/ci/bump-version/$version/bump_version.sh | head -1)

  if [ -n "$(echo $status | grep 200)" ]; then
    echo $status
    exit 0
  fi

  if [ $retry_limit -gt 0 ]; then
    retry_limit=$((retry_limit - 1))
    sleep 1
  else
    echo $status
    exit 1
  fi
done
