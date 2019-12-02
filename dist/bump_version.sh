#!/bin/bash

if [ -z "$BUMP_VERSION_FILE" ]; then
  BUMP_VERSION_FILE=.release-version
fi

if [ -z "$BUMP_IGNORE_FILE" ]; then
  BUMP_IGNORE_FILE=.bump-ignore
fi

bump_version(){
  if [ -f .bump-version.sh ]; then
    . .bump-version.sh
  else
    bump_build
  fi
}
bump_build(){
  local version
  local last
  local next
  local memo

  if [ -f $BUMP_VERSION_FILE ]; then
    last=$(cat $BUMP_VERSION_FILE)
  else
    last=0.0.0
  fi

  bump_next

  case "$next" in
    major)
      version=$((${last%%.*} + 1)).0.0
      ;;
    minor)
      memo=${last#*.}
      version=${last%%.*}.$((${memo%%.*} + 1)).0
      ;;
    patch)
      memo=${last##*.}
      version=${last%.*}.$((${memo%%-*} + 1))
      ;;
  esac

  echo $version > $BUMP_VERSION_FILE
  git add $BUMP_VERSION_FILE
}
bump_next(){
  local only_ignored
  local range

  bump_commits_range

  if [ -n "$(git log "$range" --format="%s" | grep "!" | head -1)" ]; then
    next=major
  else
    bump_check_changes
    if [ -n "$only_ignored" ]; then
      next=patch
    else
      next=minor
    fi
  fi
}
bump_check_changes(){
  local tmpdir
  local file
  local line

  if [ -f $BUMP_IGNORE_FILE ]; then
    tmpdir=.bump-version

    if [ -d $tmpdir ]; then
      return
    fi

    mkdir $tmpdir
    cp $BUMP_IGNORE_FILE $tmpdir/.gitignore

    for file in $(git diff "$range" --name-only); do
      mkdir -p $tmpdir/$(dirname $file)
      touch $tmpdir/$file
    done

    cd $tmpdir
    git init
    if [ -z "$(git status --porcelain)" ]; then
      only_ignored=true
    fi

    cd -
    rm -rf $tmpdir
  fi
}

bump_changelog(){
  local changelog=CHANGELOG.md
  local tmpfile=$changelog.tmp
  local header="# CHANGELOG"

  if [ -f $changelog ]; then
    mv $changelog $tmpfile
  fi

  bump_changelog_content > $changelog

  if [ -f $tmpfile ]; then
    rm $tmpfile
  fi

  git add $changelog
}
bump_changelog_content(){
  echo $header
  echo ""
  echo "## Version : $(cat $BUMP_VERSION_FILE)"
  echo ""

  bump_commits

  if [ -f $tmpfile ]; then
    cat $tmpfile | grep -v '^'"$header"'$'
  fi
}
bump_commits(){
  local range
  local boundary=------------------------------BOUNDARY--

  bump_commits_range

  git log "$range" --merges --format="%b$boundary" | xargs /bin/echo | sed "s/$boundary \?/\n/g" | sed "s/See/: See/" | sed "s/^\(.\)/- \1/"
}

bump_commits_range(){
  if [ -n "$(git tag | head -1)" ]; then
    range=$(git describe --abbrev=0 --tags)..
  fi
}


bump_sync(){
  local target=$1
  local pattern=$2

  sed -i "$pattern" "$target"
  git add "$target"
}


bump_version
bump_changelog

git commit -m "version bumped: $(cat $BUMP_VERSION_FILE)"
