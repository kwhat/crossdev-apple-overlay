# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="mach-o loader for linux"
HOMEPAGE="https://github.com/shinh/maloader"
SRC_URI="https://github.com/downloads/shinh/maloader/maloader-0.4.tar.gz"

LICENSE="BSD-2 BSD APSL MIT"
SLOT="0"
KEYWORDS="~x86 amd64"
IUSE=""

DEPEND="dev-libs/opencflite app-arch/p7zip"
RDEPEND="${DEPEND}"

src_configure() {
	echo "nothing to configure"
	# do nothing
}

src_compile() {
	# TODO: debug flag ->use emake all
	emake release || die "make release failed"
	mv extract maloader-extract || die
}

src_install() {
	dolib.so libmac.so || die
	dobin maloader-extract macho2elf ld-mac || die
	dobin unpack_xcode.sh binfmt_misc.sh || die
	dodoc README || die
}
