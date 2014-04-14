# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Darwin SDK header files"
HOMEPAGE="http://developer.apple.com/devcenter/mac/"
SRC_URI="MacOSX${PV/u/.Universal}.pkg"

LICENSE="APSL-2"
SLOT="${PV}"

KEYWORDS="amd64 x86"
IUSE=""
RESTRICT="fetch strip"

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} = ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi
is_cross() { [[ ${CHOST} != ${CTARGET} ]] ; }

DEPEND="app-arch/cpio
	app-arch/p7zip"
RDEPEND=""

if is_cross ; then
	DEPEND="${DEPEND} =sys-devel/${P}"
fi

pkg_nofetch() {
	eerror "Please go to"
	eerror "    ${HOMEPAGE}"
	eerror "and download the Xcode and iOS SDK cd image."
	eerror "Extract the image using "
	eerror "    7z e <image>.dmg 5.hfs && \\"
	eerror "    7z e 5.hfs Xcode/Packages/MacOSX${PV}.pkg -o${DISTDIR}"
}

src_unpack() {
	7z x ${DISTDIR}/${A} -y -o${T} && \
	7z x ${T}/Payload -y -o${T} && \
	cpio -i < ${T}/Payload~

	mv SDKs ${P}
}

src_copile() {
	mv %{T}/MacOSX${PV}.sdk/*
}

src_install() {
	if ! is_cross ; then
		dosym /opt/MacOSX${PV}.sdk/usr /usr/${CTARGET}/usr
	else
		dodir /opt/MacOSX${PV}.sdk
		mv "${WORKDIR}"/${P}/MacOSX${PV}.sdk/* "${ED}"/opt/MacOSX${PV}.sdk
		dosym /opt/MacOSX${PV}.sdk/System/Library/Frameworks /opt/MacOSX${PV}.sdk/Library/Frameworks
	fi
}
