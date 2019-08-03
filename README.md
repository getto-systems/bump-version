# version-dump

version dump script

```bash
GIT_USER_EMAIL="user-name@example.com" GIT_USER_NAME="user-name" ./bin/version_dump.sh
```


###### Table of Contents

- [Requirements](#Requirements)
- [Usage](#Usage)
- [License](#License)

## Requirements

- bash


## Usage

```bash
GIT_USER_EMAIL="user-name@example.com" GIT_USER_NAME="user-name" ./bin/version_dump.sh
```

- create CHANGELOG.md
- create .release-version
- `git commit -m "version dump : $(cat .release-version)"`


### version rule

- major version up : there is commit that include `!` in commit message since last version-up
- minor version up : there is not-ignorable file changes since last version-up
- patch version up : there is only ignorable file changes since last version-up


#### ignorable changes

specify ignorable files in `.releaseignore` file

`.releaseignore` example(same syntax as gitignore)

```gitignore
/*
!/src/
```

- basically, ignore all files
- `/src/` files are not-ignorable


## License

version-dump is licensed under the [MIT](LICENSE) license.

Copyright &copy; since 2019 shun@getto.systems

