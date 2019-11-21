#!/bin/sh

set -x

message=$1
branch=$(echo "$message" | head -1 | sed -e "s/[^[:alnum:]]\+/-/g")

if [ -z "$branch" ]; then
  echo "source branch name is not detected"
  exit 1
fi

git clone https://github.com/getto-systems/git-post.git

cwd=$(pwd)
export PATH=$PATH:$cwd/git-post/bin

git checkout -b "$branch"
git commit -m "$message"

super=$(git remote -v | grep "origin.*fetch" | sed 's|.*https|https|' | sed "s|gitlab-ci-token:.*@|$GITLAB_USER:$GITLAB_ACCESS_TOKEN@|" | sed "s| .*||")
git push $super $branch:$branch

git post "$message" master
