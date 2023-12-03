# PowerShell Profile

This adds machine wide environment variables on Linux machines.

The two are

```
POWERSHELL_TELEMETRY_OPTOUT=true
POWERSHELL_UPDATECHECK=Off
```

This is to stop network telemetry and version control checking.

For `Debian` and `RPM` based systems, use [package.sh](package.sh)

For `Arch Linux` use [PKGBUILD](PKGBUILD) with `makepkg`

For `Alpine` use [APKBUILD](APKBUILD) with `abuild`

These scripts create packages. Install the packages to add the configuration.
