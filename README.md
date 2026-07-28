# focalcrest-rockchip-yocto

Yocto project for bringing up Focalcrest Rockchip boards. Its purpose is to
validate mainline kernel / U-Boot on Focalcrest hardware; it is not a shipping
distribution.

The BSP layer itself is documented in
[`layers/meta-focalcrest/README.md`](layers/meta-focalcrest/README.md).

## Build

```sh
git clone --recurse-submodules <url> focalcrest-rockchip-yocto
cd focalcrest-rockchip-yocto
. ./setup-env.sh                    # defaults to build-az07
bitbake focalcrest-image-bringup
```

Artifacts land in `build-az07/tmp/deploy/images/<MACHINE>/`.

## Layers

| Path | Origin | Branch |
|---|---|---|
| `layers/bitbake` | git.openembedded.org/bitbake | 2.18 |
| `layers/openembedded-core` | git.openembedded.org/openembedded-core | wrynose |
| `layers/meta-openembedded` | github.com/openembedded/meta-openembedded | wrynose |
| `layers/meta-arm` | git.yoctoproject.org/meta-arm | wrynose |
| `layers/meta-rockchip` | git.yoctoproject.org/meta-rockchip | wrynose |
| `layers/meta-focalcrest` | this repository | — |

Upstream layers are pinned as submodules; `git submodule status` is the current
baseline.

## Supported machines

| MACHINE | SoC |
|---|---|
| `rk3566-focalcrest-az07` | RK3566 |
| `rk3566-autonomic-m1` | RK3566 |
| `rk3576s-focalcrest-az08` | RK3576S |
| `rk3588s-focalcrest-az04b` | RK3588S |
