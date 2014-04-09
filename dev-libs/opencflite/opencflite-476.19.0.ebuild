# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="A cross platform toolkit for building applications on Mac OS X, Windows, and Linux."
HOMEPAGE="http://sourceforge.net/projects/opencflite/"
SRC_URI="http://downloads.sourceforge.net/project/opencflite/opencflite/476.19.0/opencflite-476.19.0.tar.gz"

LICENSE="APSL-2"
SLOT="0"
KEYWORDS="~x86 amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_configure() {
	econf --with-tz-includes=${FILESDIR}
}

src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc CHANGES CONTRIBUTORS INSTALL README TODO || die
}
