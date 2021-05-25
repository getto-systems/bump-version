# bump-version

bumping version

state: production ready

```bash
curl https://trellis.getto.systems/ci/bump-version/VERSION/dist/bump_version.sh | bash
curl https://trellis.getto.systems/ci/bump-version/VERSION/dist/request.sh | bash -s -- ./.bump-message.sh
curl https://trellis.getto.systems/ci/bump-version/VERSION/dist/push_tags.sh | bash
```

###### Table of Contents

-   [Requirements](#Requirements)
-   [Usage](#Usage)
-   [License](#License)

## Requirements

-   bash
-   git

## Usage

### bumping version

```bash
curl https://trellis.getto.systems/ci/bump-version/VERSION/dist/bump_version.sh | bash
```

-   bumping version string to `.release-version`
-   git commit

#### Customize

-   `BUMP_VERSION_FILE`: specify "release-version" file; default: `.release-version`
-   `BUMP_MAJOR_FILE`: specify "bump-major-release" file; default: `.bump-major-release`
-   `BUMP_IGNORE_FILE`: specify "bump-ignore" file; default: `.bump-ignore`
-   `BUMP_SCRIPT`: specify "bump-script" file; default: `.bump-version.sh`
-   `BUMP_VERSION_SUFFIX`: specify version suffix; default: empty

#### versioning rule

-   major version up : there is bump-major-release file
-   minor version up : there is not-ignorable file changes since last version-up
-   patch version up : there is only ignorable file changes since last version-up

#### bump-major-release file

this file will be used to determine the major version up

this file will be deleted when main-script run

#### bump-ignore file

`.bump-ignore` example(same syntax as gitignore)

```gitignore
/*
!/src/
```

#### bump-script file

this file will load from main-script

if this file is missing, the following script will be run

```bash
bump_build
```

`.bump-version.sh` example

```bash
bump_build
bump_sync package.json 's/"version": "[0-9.-]\+"/"version": "'$(cat .release-version)'"/'
```

-   `bump_build` : build `.release-version` file
-   `bump_sync` : helper command: sed and git add

### create pull request

```bash
curl https://trellis.getto.systems/ci/bump-version/VERSION/dist/request.sh | bash -s -- ./.bump-message.sh
```

-   generate message by `./.bump-message.sh` (first argument : executable file)
-   create pull request (supported: GitLab only)

### push tags

```bash
curl https://trellis.getto.systems/ci/bump-version/VERSION/dist/push_tags.sh | bash
```

-   `git push --tags` : to origin
-   `git push --tags` : to `.git-maint-repo` if exists

#### Customize

-   `BUMP_TAG_SCRIPT`: specify bump-tag-script file; default: `.bump-version-tag.sh`
-   `BUMP_MAINT_REPO_FILE`: specify maint-repo file; default: `.git-maint-repo`

#### bump-tag-script file

this file will load from main-script

if this file is missing, the following script will be run

```bash
git tag $(cat $BUMP_VERSION_FILE)
```

## License

bump-version is licensed under the [MIT](LICENSE) license.

Copyright &copy; since 2019 shun@getto.systems
