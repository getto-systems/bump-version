#!/bin/sh

set -x

if [ ! -x "$1" ]; then
  echo "usage: ./request.sh /path/to/message.sh"
  exit 1
fi

message=$($1)
branch=$(echo "$message" | head -1 | sed -e "s/[^[:alnum:]]\+/-/g")

if [ -z "$branch" ]; then
  echo "source branch name is not detected"
  exit 1
fi

git checkout -b "$branch"
git commit -m "$message"

super=$(git remote -v | grep "origin.*fetch" | sed 's|.*https|https|' | sed "s|gitlab-ci-token:.*@|$GITLAB_USER:$GITLAB_ACCESS_TOKEN@|" | sed "s| .*||")
git push $super $branch:$branch

git post "$message" master
