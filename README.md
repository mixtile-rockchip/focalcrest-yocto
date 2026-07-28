# focalcrest-yocto

Focalcrest Rockchip 板级调试用 Yocto 工程。用于验证 mainline 内核 / U-Boot
在 Focalcrest 板上的可用性,不用于出货。

BSP 层本身的说明见 [`layers/meta-focalcrest/README.md`](layers/meta-focalcrest/README.md)。

## 构建

```sh
git clone --recurse-submodules <url> focalcrest-yocto
cd focalcrest-yocto
. ./setup-env.sh                    # 默认 build-az07
bitbake focalcrest-image-bringup
```

产物在 `build-az07/tmp/deploy/images/<MACHINE>/`。

## 层构成

| 路径 | 来源 | 分支 |
|---|---|---|
| `layers/bitbake` | git.openembedded.org/bitbake | 2.18 |
| `layers/openembedded-core` | git.openembedded.org/openembedded-core | wrynose |
| `layers/meta-openembedded` | github.com/openembedded/meta-openembedded | wrynose |
| `layers/meta-arm` | git.yoctoproject.org/meta-arm | wrynose |
| `layers/meta-rockchip` | git.yoctoproject.org/meta-rockchip | wrynose |
| `layers/meta-focalcrest` | 本仓 | — |

上游层以 submodule 钉死 commit,`git submodule status` 即为当前基线。

## 已支持机器

| MACHINE | SoC |
|---|---|
| `rk3566-focalcrest-az07` | RK3566 |
