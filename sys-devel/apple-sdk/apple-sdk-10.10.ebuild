# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Darwin SDK header files"
HOMEPAGE="http://developer.apple.com/devcenter/mac/"
SRC_URI="${P}.tar.bz2"

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

DEPEND="app-arch/p7zip"
RDEPEND=""

S="${WORKDIR}"/MacOSX${PV}.sdk

pkg_nofetch() {
	eerror "Please go to"
	eerror "    ${HOMEPAGE}"
	eerror "and download the Command Line Tools (OS X ${PV}) Xcode 6.1.1."
	eerror "Extract the image using "
	eerror "    7z e <image>.dmg ?.hfs && \\"
	eerror "    mkdir tmp && \\"
	eerror "    mount -oloop ?.hfs ./tmp &&\\"
	eerror "    7z x ./tmp/*.pkg DevSDK_OSX1010.pkg/Payload &&\\"
	eerror "    mv DevSDK_OSX${PN/./}.pkg ./MacOSX${PV}.sdk &&\\"
	eerror "    cd ./MacOSX${PV}.sdk &&\\"
	eerror "    7z x ./Payload && \\"
	eerror "    cpio -i < ./Payload~ && \\"
	eerror "    rm -v ./Payload* && \\"
	eerror "    cd .. && \\"
	eerror "    tar cjvf ${DISTDIR}/${P}.tar.bz2 ./MacOSX${PV}.sdk"
	einfo "Note: You may require CONFIG_HFS_FS and BLK_DEV_LOOP to mount the hfs partition."
}

src_install() {
	dist=/opt/MacOSX${PV}.sdk

	if is_cross ; then
		dist=/usr/${CTARGET}
	fi

	dodir ${dist}
	mv "${WORKDIR}"/${P}/MacOSX${PV}.sdk/* "${ED}"${dist}
	dosym ${dist}/System/Library/Frameworks ${dist}/Library/Frameworks
}
