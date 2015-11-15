# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils git-2

DESCRIPTION="Darwin SDK header files"
HOMEPAGE="http://developer.apple.com/devcenter/mac/"
EGIT_REPO_URI="git://github.com/kwhat/${PN}.git"
EGIT_BRANCH="${PV}"

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

KEYWORDS="-amd64 -x86"
RESTRICT="strip"

DEPEND=""
RDEPEND=""

S="${WORKDIR}"/MacOSX${PV}.sdk

src_install() {
	dist=/opt/MacOSX${PV}.sdk

	if is_cross ; then
		dist=/usr/${CTARGET}
	fi

	dodir ${dist}
	mv "${WORKDIR}"/MacOSX${PV}.sdk/* "${ED}"${dist}
	dosym ${dist}/System/Library/Frameworks ${dist}/Library/Frameworks
}
