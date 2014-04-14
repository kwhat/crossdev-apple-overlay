# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Darwin SDK header files"
HOMEPAGE="http://developer.apple.com/devcenter/mac/"
SRC_URI="MacOSX${PV/u/.Universal}.pkg"

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} = ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi
is_cross() { [[ ${CHOST} != ${CTARGET} ]] ; }

LICENSE="APSL-2"
if is_cross ; then
	SLOT="${CTARGET}-${PV}"
else
	SLOT="${PV}"
fi

KEYWORDS="~amd64 ~x86"
RESTRICT="fetch strip"

DEPEND="app-arch/cpio
	app-arch/p7zip"
RDEPEND=""

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

#src_copile() {
#	use crosscompile_opts_headers-only || mv %{T}/MacOSX${PV}.sdk/*
#}

src_install() {
	dist=/opt/MacOSX${PV}.sdk/usr

	if is_cross ; then
		dist=/usr/${CTARGET}/usr
	fi

	dodir ${dist}
	mv "${WORKDIR}"/${P}/MacOSX${PV}.sdk/* "${ED}"${dist}
	dosym ${dist}/System/Library/Frameworks ${dist}/Library/Frameworks
}
