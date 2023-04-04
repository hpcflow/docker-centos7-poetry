# docker-centos7-poetry

Dockerfile for running Python 3.9 and poetry within a CentOS 7 container. This is useful for running Pyinstaller to generate executables that use older versions of GLIBC. E.g. see [this discussion](https://github.com/pyinstaller/pyinstaller/discussions/5669).

**Example GitHub action that uses this container with PyInstaller**

```yaml
name: build-executables
on:
  workflow_dispatch:
jobs:
  build-executable-CentOS:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/hpcflow/centos7-poetry
    steps:
      - uses: actions/checkout@v2

      - name: Install dependencies
        run: poetry install

      - name: Run PyInstaller
        run: poetry run pyinstaller hpcflow/cli.py --name=hpcflow --onefile
```

# Build steps (hosting in ghcr)

The version tag is specified after the `:`, and should include the python and poetry versions:
```
docker build -t ghcr.io/hpcflow/centos7-poetry:py3.9.16_po1.4.2 .
docker push ghcr.io/hpcflow/centos7-poetry:py3.9.16_po1.4.2
```

When updating the latest image use the tag `latest`:
```
docker build -t ghcr.io/hpcflow/centos7-poetry:latest .
docker push ghcr.io/hpcflow/centos7-poetry:latest
```
<ins>**Make sure to push the image twice**</ins>! Once with the version tag and another with the latest tag.

> **Note:** you may have to login to ghcr before pushing.
> For that, first create a personal access token
> (Settings / Developer settings / New token (classic))
> with permissions for write and delete packages.
> Copy the access token!
> 
> Then use your github username and the copied acces token to login with
> ```
> docker login ghcr.io
> ```
> You should now be ready to push.
