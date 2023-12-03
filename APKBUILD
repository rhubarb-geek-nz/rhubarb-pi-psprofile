# Contributor: rhubarb-geek-nz <rhubarb-geek-nz@users.sourceforge.net>
# Maintainer: rhubarb-geek-nz <rhubarb-geek-nz@users.sourceforge.net>
pkgname=rhubarb-pi-psprofile
pkgver=1.0
pkgrel=0
pkgdesc="PowerShell Profile"
url="https://github.com/rhubarb-geek-nz/rhubarb-pi-psprofile"
arch="noarch"
license="MIT"
depends=""
makedepends=""
checkdepends=""
install=""
subpackages=""
source=""
builddir="$srcdir/"

build() {
	mkdir -p "$srcdir/etc/profile.d"
	cat << EOF > "$srcdir/etc/profile.d/rhubarb-pi-psprofile.sh"
POWERSHELL_TELEMETRY_OPTOUT=true
POWERSHELL_UPDATECHECK=Off
export POWERSHELL_TELEMETRY_OPTOUT
export POWERSHELL_UPDATECHECK
EOF
}

check() {
	:
}

package() {
	install -d "$pkgdir/etc"
	tar -cf - $(find etc -type f) | tar xf - -C "$pkgdir"
}
