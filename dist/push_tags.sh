#!/usr/bin/env sh

if [ -x ./.bump-version-tag.sh ]; then
  ./.bump-version-tag.sh
else
  if [ -z "$BUMP_VERSION_FILE" ]; then
    BUMP_VERSION_FILE=.release-version
  fi

  git tag $(cat $BUMP_VERSION_FILE)
fi

super=$(git remote -v | grep "origin.*fetch" | sed 's|.*https|https|' | sed "s|gitlab-ci-token:.*@|$GITLAB_USER:$GITLAB_ACCESS_TOKEN@|" | sed "s| .*||")

default_branch=$(git ls-remote --symref ${super} HEAD | grep ref: | awk '{ print $2 }' | sed 's|^refs/heads/||')

git push $super HEAD:${default_branch} --tags

if [ $? != 0 ]; then
  exit 1
fi

if [ -f .git-maint-repo ]; then
  maint_repo=$(cat .git-maint-repo)
  case "$maint_repo" in
    https://bitbucket.org*)
      maint=$(echo $maint_repo | sed "s|https://|https://$BITBUCKET_USER:$BITBUCKET_ACCESS_TOKEN@|")
      ;;
    https://github.com*)
      maint=$(echo $maint_repo | sed "s|https://|https://$GITHUB_USER:$GITHUB_ACCESS_TOKEN@|")
      ;;
  esac

  if [ -z "$maint" ]; then
    echo "unknown hosting service: $maint_repo"
    exit 1
  fi

  default_branch=$(git ls-remote --symref ${maint} HEAD | grep ref: | awk '{ print $2 }' | sed 's|^refs/heads/||')
  git push "$maint" HEAD:${default_branch} --tags
fi
