#!/bin/sh -e
# Copyright (c) 2023 Roger Brown.
# Licensed under the MIT License.

cleanup()
{
	for d in data control
	do
		if test -d $d
		then
			chmod -R +w $d
		fi
	done
	rm -rf control.tar.* control data data.tar.* debian-binary rpm.spec rpms
}

cleanup

rm -f *.deb *.rpm

trap cleanup 0

VERSION="1.0"
DPKGARCH=all
PKGNAME=rhubarb-pi-psprofile
CONFIGFILE=/etc/profile
RELEASE=1

mkdir control data

mkdir -p "data$CONFIGFILE.d"
cat > "data$CONFIGFILE.d/$PKGNAME.sh" <<EOF
POWERSHELL_TELEMETRY_OPTOUT=true
POWERSHELL_UPDATECHECK=Off
export POWERSHELL_TELEMETRY_OPTOUT
export POWERSHELL_UPDATECHECK
EOF

find data -type f | xargs chmod -w 
find data -type f | xargs chmod go+r

if dpkg --print-architecture 2>/dev/null
then
	if test -z "$MAINTAINER"
	then
		echo MAINTAINER must be specified >&2
		false
	fi

	DEBFILE="$PKGNAME"_"$VERSION"-"$RELEASE"_"$DPKGARCH".deb

	cat > control/control <<EOF
Package: $PKGNAME
Version: $VERSION-$RELEASE
Architecture: $DPKGARCH
Maintainer: $MAINTAINER
Section: admin
Priority: extra
Description: Environment for PowerShell
EOF

	for d in control data
	do
		(
			set -e
			cd $d
			find * -type f | tar --owner=0 --group=0 --create --gzip --file ../$d.tar.gz --files-from -
		)
	done

	rm -rf "$DEBFILE"

	echo "2.0" >debian-binary

	ar r "$DEBFILE" debian-binary control.tar.* data.tar.*
fi

if rpmbuild --version 2>/dev/null
then
	(
		cat <<EOF
Summary: Environment for PowerShell
Name: $PKGNAME
Version: $VERSION
Release: $RELEASE
Group: Applications/System
License: MIT
BuildArch: noarch
Prefix: /
%description
Environment for PowerShell

EOF

		cat << EOF
%files
%defattr(-,root,root)
EOF

		(
			cd data
			find etc -type f | while read N
			do
				echo "/$N"
			done
		)

		cat << EOF
%clean
EOF
	) > rpm.spec

	PWD=$(pwd)
	rpmbuild --buildroot "$PWD/data" --define "_rpmdir $PWD/rpms" -bb "$PWD/rpm.spec"

	find rpms -type f -name "*.rpm" | while read N
	do
		mv "$N" .
		basename "$N"
	done
fi
