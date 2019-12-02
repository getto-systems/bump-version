# bump-version

bumping version

```bash
cat ./bin/bump_version.sh | bash
cat ./bin/request.sh | bash -s -- ./.bump-message.sh
cat ./bin/push_tags.sh | bash
```


###### Table of Contents

- [Requirements](#Requirements)
- [Usage](#Usage)
- [License](#License)

## Requirements

- bash


## Usage

### bumping version

```bash
cat ./bin/bump_version.sh | bash
```

- modify CHANGELOG.md
- modify .release-version
- `git commit -m "version bumped : $(cat .release-version)"`


#### Customize

`.bump-version.sh`

```bash
bump_build
bump_sync package.json 's/"version": "[0-9.-]\+"/"version": "'$version'"/'
```

- `bump_build` : build `.release-version` file
- `bump_sync` : sed and git add


#### version rule

- major version up : there is commit that include `!` in commit message since last version-up
- minor version up : there is not-ignorable file changes since last version-up
- patch version up : there is only ignorable file changes since last version-up


#### .bumpignore file

specify ignorable files in `.bumpignore` file

`.bumpignore` example(same syntax as gitignore)

```gitignore
/*
!/src/
```

- basically, ignore all files
- `/src/` files are not-ignorable

### create pull request

```bash
cat ./bin/request.sh | bash -s -- ./.bump-message.sh
```

- generate message by `./.bump-message.sh` (first argument : executable file)
- create pull request (supported: GitLab only)

### push tags

```bash
cat ./bin/push_tags.sh | bash
```

- `git push --tags` : to origin
- `git push --tags` : to `.git-maint-repo` if exists


## License

bump-version is licensed under the [MIT](LICENSE) license.

Copyright &copy; since 2019 shun@getto.systems

