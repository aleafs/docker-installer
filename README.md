# About

离线环境下 `Linux` 上 `Docker` 和 `docker compose`安装包。

## How to use

```bash
./install.sh
```

## nfpm

```bash
SEMVER="${VERSION}" nfpm package -f ./nfpm.yaml -p [deb|rpm]
```

## TODO

### `/etc/docker/daemon.json`

- [ ] Network 配置
- [ ] Volume 配置