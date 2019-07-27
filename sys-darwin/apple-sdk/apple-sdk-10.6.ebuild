# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils git-r3

DESCRIPTION="Darwin SDK header files"
HOMEPAGE="http://developer.apple.com/devcenter/mac/"
EGIT_REPO_URI="https://github.com/kwhat/${PN}"
EGIT_BRANCH="${PV}"

LICENSE="APSL-2"
SLOT="${PV}"

KEYWORDS="~amd64 ~x86"
RESTRICT="strip"

DEPEND=""
RDEPEND=""

src_install() {
	dist=/opt/MacOSX${PV}.sdk

	einfo "${ED}"${dist}
	dodir ${dist}
	cp -RPv "${S}"/* "${ED}"${dist}

	dosym ${dist}/System/Library/Frameworks ${dist}/Library/Frameworks
}
