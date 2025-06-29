# About

离线环境下 `Linux` 上 `Docker` 和 `docker compose`安装包。

# Tag & Version

此仓库的`tag`与`docker engine`版本（MAJOR.MINOR.PATCH）追求一致。`v27.5.1`包含如下组件：

* `docker engine`: 27.5.1
* `docker-compose`: 2.33.0

# OS Compatibility

感谢[阿里云市场](https://market.aliyun.com/products/57742013?page=1)提供常见操作系统镜像供验证。

| Platform           | 包管理  |   x86_64 / amd64   |  aarch64 / arm64   |
|:-------------------|:----:|:------------------:|:------------------:|
| CentOS 7           | rpm  | :white_check_mark: |                    |
| RHEL               | rpm  | :white_check_mark: | :white_check_mark: |
| SUSE Linux 15      | rpm  | :white_check_mark: |                    |
| Kylin v10          | rpm  | :white_check_mark: | :white_check_mark: |
| openEuler 20/22/24 | rpm  | :white_check_mark: |                    |
| Ubuntu 22          | dpkg | :white_check_mark: |                    |