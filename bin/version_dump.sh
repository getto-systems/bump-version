#!/bin/bash

release_changelog(){
  local changelog=CHANGELOG.md
  local tmp=$changelog.tmp
  local header="# CHANGELOG"

  if [ -f $changelog ]; then
    mv $changelog $tmp
  fi

  release_dump_changelog > $changelog

  git add $changelog
}
release_dump_changelog(){
  echo $header
  echo ""
  echo "## Version : $(cat .release-version)"
  echo ""

  release_show_commits

  if [ -f $tmp ]; then
    cat $tmp | grep -v '^'"$header"'$'
    rm $tmp
  fi
}
release_show_commits(){
  local range
  local boundary=------------------------------BOUNDARY--

  release_range

  git log "$range" --merges --format="%b$boundary" | xargs /bin/echo | sed "s/$boundary \?/\n/g" | sed "s/^/- /"
}

release_version(){
  if [ -f .release-version-dump.sh ]; then
    . .release-version-dump.sh
  else
    release_build_version
  fi
}
release_build_version(){
  local version
  local last
  local next
  local tmp

  if [ -f .release-version ]; then
    last=$(cat .release-version)
  else
    last=0.0.0
  fi

  release_next_version

  case "$next" in
    major)
      version=$((${last%%.*} + 1)).0.0
      ;;
    minor)
      tmp=${last#*.}
      version=${last%%.*}.$((${tmp%%.*} + 1)).0
      ;;
    patch)
      tmp=${last##*.}
      version=${last%.*}.$((${tmp%%-*} + 1))
      ;;
  esac

  echo $version > .release-version
  git add .release-version
}
release_next_version(){
  local only_ignored
  local range

  release_range

  if [ -n "$(git log "$range" --format="%s" | grep "!" | head -1)" ]; then
    next=major
  else
    release_only_ignored
    if [ -n "$only_ignored" ]; then
      next=patch
    else
      next=minor
    fi
  fi
}
release_only_ignored(){
  local ignore=.releaseignore
  local tmp
  local file
  local line

  if [ -f $ignore ]; then
    tmp=.release

    if [ -d $tmp ]; then
      return
    fi

    mkdir $tmp
    cp $ignore $tmp/.gitignore

    for file in $(git diff "$range" --name-only); do
      mkdir -p $tmp/$(dirname $file)
      touch $tmp/$file
    done

    cd $tmp
    git init
    if [ -z "$(git status --porcelain)" ]; then
      only_ignored=true
    fi

    cd -
    rm -rf $tmp
  fi
}

release_range(){
  if [ -n "$(git tag | head -1)" ]; then
    range=$(git describe --abbrev=0 --tags)..
  fi
}

release_sync_version(){
  local target=$1
  local version=$(cat .release-version)

  case "$target" in
    mix.exs)
      sed -i 's/version: "[0-9.-]\+"/version: "'$version'"/' "$target"
      ;;
    package.json|elm-package.json)
      sed -i 's/"version": "[0-9.-]\+"/"version": "'$version'"/' "$target"
      ;;
    *.rb)
      sed -i 's/VERSION = "[0-9.-]\+"/VERSION = "'$version'"/' "$target"
      ;;
    Chart.yaml)
      sed -i 's/^version: [0-9.-]\+/version: '$version'/' "$target"
      ;;
    Cargo.toml)
      sed -i 's/version = "[0-9.-]\+"/version = "'$version'"/' "$target"
      ;;
  esac

  git add "$target"
}

release_version
release_changelog

git config user.email "$GIT_USER_EMAIL"
git config user.name "$GIT_USER_NAME"

git commit -m "version dump: $(cat .release-version)"
