# Maintainer: rhubarb-geek-nz@users.sourceforge.net
pkgname=rhubarb-pi-psprofile
pkgver=1.0
pkgrel=1
epoch=
pkgdesc="PowerShell Profile"
arch=('any')
url="https://github.com/rhubarb-geek-nz/rhubarb-pi-psprofile"
license=('MIT')
groups=()
depends=()
makedepends=()
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
noextract=()
md5sums=()
validpgpkeys=()

prepare() {
	mkdir "$pkgname-$pkgver"
}

build() {
	cd "$pkgname-$pkgver"
	mkdir -p "etc/profile.d"
	(
		umask 333
		cat << EOF > "etc/profile.d/rhubarb-pi-psprofile.sh"
POWERSHELL_TELEMETRY_OPTOUT=true
POWERSHELL_UPDATECHECK=Off
export POWERSHELL_TELEMETRY_OPTOUT
export POWERSHELL_UPDATECHECK
EOF
	)
}

check() {
	:
}

package() {
	tar cf - -C "$pkgname-$pkgver" etc | tar xf - -C "$pkgdir"
}
