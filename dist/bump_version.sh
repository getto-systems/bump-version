#!/usr/bin/env sh

set -x

if [ -z "$BUMP_VERSION_FILE" ]; then
  BUMP_VERSION_FILE=.release-version
fi

if [ -z "$BUMP_IGNORE_FILE" ]; then
  BUMP_IGNORE_FILE=.bump-ignore
fi

if [ -z "$BUMP_MAJOR_FILE" ]; then
  BUMP_MAJOR_FILE=.bump-major-release
fi

if [ -z "$BUMP_SCRIPT" ]; then
  BUMP_SCRIPT=.bump-version.sh
fi

if [ -z "$BUMP_VERSION_SUFFIX" ]; then
  BUMP_VERSION_SUFFIX=
fi

if [ -f $BUMP_VERSION_FILE ]; then
  BUMP_LAST_VERSION=$(cat $BUMP_VERSION_FILE)
else
  BUMP_LAST_VERSION=0.0.0
fi

bump_main() {
  bump_version
  git commit -m "version bumped: $(cat $BUMP_VERSION_FILE)"
}

bump_version() {
  if [ -f $BUMP_SCRIPT ]; then
    . $BUMP_SCRIPT
  else
    bump_build
  fi
}
bump_build() {
  local version
  local next
  local memo

  bump_next

  case "$next" in
  major)
    version=$((${BUMP_LAST_VERSION%%.*} + 1)).0.0
    ;;
  minor)
    memo=${BUMP_LAST_VERSION#*.}
    version=${BUMP_LAST_VERSION%%.*}.$((${memo%%.*} + 1)).0
    ;;
  patch)
    memo=${BUMP_LAST_VERSION##*.}
    version=${BUMP_LAST_VERSION%.*}.$((${memo%%-*} + 1))
    ;;
  esac

  echo "${version}${BUMP_VERSION_SUFFIX}" >$BUMP_VERSION_FILE
  git add $BUMP_VERSION_FILE
}
bump_next() {
  local only_ignored

  if [ -f $BUMP_MAJOR_FILE ]; then
    git rm $BUMP_MAJOR_FILE
    next=major
    return
  fi

  bump_check_changes
  if [ -n "$only_ignored" ]; then
    next=patch
  else
    next=minor
  fi
}
bump_check_changes() {
  local tmpdir
  local file
  local range

  if [ -f $BUMP_IGNORE_FILE ]; then
    tmpdir=.bump-version-check-changes-tmp-dir

    if [ -d $tmpdir ]; then
      return
    fi

    mkdir $tmpdir
    cp $BUMP_IGNORE_FILE $tmpdir/.gitignore

    bump_commits_range

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

bump_commits_range() {
  git fetch --tags --unshallow
  if [ -n "$(git tag -l $BUMP_LAST_VERSION)" ]; then
    range=${BUMP_LAST_VERSION}..
  fi
}

# helper command use in BUMP_SCRIPT
bump_sync() {
  local target=$1
  local pattern=$2

  sed -i "$pattern" "$target"
  git add "$target"
}

bump_main "$@"
