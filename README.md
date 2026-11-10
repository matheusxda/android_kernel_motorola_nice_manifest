# Motorola Moto G86 5G (nice) — Kernel Manifest

Manifest repository for building the Linux kernel for the **Motorola Moto G86 5G (`nice`)**, based on the Android 17 platform.

## Manifest Information

| Property | Details |
| --- | --- |
| Device | Motorola Moto G86 5G |
| Codename | `nice` |
| Android Version | 17 |
| Release Tag | `MMI-A171VNH.50-16` |

## Device Specifications

| Item | Specifications |
| --- | --- |
| Chipset | MediaTek Dimensity 7300 (`mt6878`) |
| CPU | 4x Cortex-A78 2.5 GHz + 4x Cortex-A55 2.0 GHz |
| GPU | Arm Mali-G615 MC2 |
| RAM | 8 / 12 GB |
| Storage | 256 / 512 GB |
| Shipped Android Version | 15 |
| Display | 6.67-inch pOLED, 2712 x 1220 |
| Battery | 5200 mAh Li-Po (non-removable) |

## Building

To start building the kernel, run the following command in your terminal:

```bash
curl -LSs "https://raw.githubusercontent.com/matheusxda/android_kernel_motorola_nice_manifest/refs/heads/MMI-A171VNH.50-16/build.sh" | bash
```

The build script also support using more options:

```bash
curl -LO "https://raw.githubusercontent.com/matheusxda/android_kernel_motorola_nice_manifest/refs/heads/MMI-A171VNH.50-16/build.sh"
chmod +x build.sh
./build.sh --help
```

## Disclaimer

This project is provided for development and educational purposes.

**Use at your own risk.**

Building or flashing a modified Android kernel can result in boot loops, crashes, data loss, device soft-bricks, or other unexpected behavior.

## Credits

Thanks to everyone that contributed to the project:

| Project | Author / Maintainer |
| --- | --- |
| [Moto G86 Android 15 Kernel Manifest](https://github.com/dx0101x/motorola_nice_manifest) | [@dx0101x](https://github.com/dx0101x) |
