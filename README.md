# docker-centos7-poetry

Dockerfile for running Python 3.9 and poetry within a CentOS 7 container. This is useful for running Pyinstaller to generate executables that use older versions of GLIBC. E.g. see [this discussion](https://github.com/pyinstaller/pyinstaller/discussions/5669).

**Example GitHub action that uses this container**

```yaml
name: build-executables
on:
  workflow_dispatch:
jobs:
  build-executable-CentOS:
    runs-on: ubuntu-latest
    container:
      image: aplowman/centos7-poetry
    steps:
      - uses: actions/checkout@v2

      - name: Install dependencies
        run: poetry install

      - name: Run PyInstaller
        run: poetry run pyinstaller hpcflow/cli.py --name=hpcflow --onefile
```
