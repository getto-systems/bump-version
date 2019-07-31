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


## License

version-dump is licensed under the [MIT](LICENSE) license.

Copyright &copy; since 2019 shun@getto.systems

