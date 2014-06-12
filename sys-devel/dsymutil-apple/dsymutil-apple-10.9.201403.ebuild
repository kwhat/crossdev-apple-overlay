# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Apple utility to manipulate archived DWARF debug symbol files."
HOMEPAGE="http://developer.apple.com/devcenter/mac/"
SRC_URI="${P}.tar.bz2"

LICENSE="APSL-2"
SLOT="${PV}"

KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="fetch strip"

DEPEND="app-arch/cpio
	app-arch/p7zip
	app-emulation/maloader[libcxx]"
RDEPEND=""


pkg_nofetch() {
	eerror "Please go to"
	eerror "    ${HOMEPAGE}"
	eerror "and download the March 2014 command line tools for OS X 10.9."
	eerror "Extract the image using "
	eerror "    7z e <image>.dmg ?.hfs && \\"
	eerror "    7z e ?.hfs \"Command Line Developer Tools\"/Packages/CLTools_Executables.pkg && \\"
	eerror "    7z e CLTools_Executables.pkg Payload && \\"
	eerror "    7z x Payload && \\"
	eerror "    cpio -i < Payload~ && \\"
	eerror "    cd Library/Developer/CommandLineTools && \\"
	eerror "    tar cjvf ${DISTDIR}/${P}.tar.bz2 usr/bin/dsymutil"
}

S="${WORKDIR}"

src_compile() {
	mv usr/bin/dsymutil dsymutil-apple
	cp ${FILESDIR}/dsymutil dsymutil
}

src_install() {
	dobin dsymutil
	dobin dsymutil-apple
}
