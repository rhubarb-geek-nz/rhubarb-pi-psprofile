# PowerShell Profile

This adds machine wide environment variables on Linux machines.

The two are

```
POWERSHELL_TELEMETRY_OPTOUT=true
POWERSHELL_UPDATECHECK=Off
```

This is to stop network telemetry and version control checking.

For `Debian` and `RPM` based systems, use [package.sh](linux/package.sh)

For `Arch Linux` use [PKGBUILD](pacman/PKGBUILD) with `makepkg`

For `Alpine` use [APKBUILD](alpine/APKBUILD) with `abuild`

These scripts create packages. Install the packages to add the configuration.
