# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2

SRC_URI=""
KEYWORDS="~amd64 ~x86"
EGIT_REPO_URI="git://github.com/shinh/maloader.git"

DESCRIPTION="mach-o loader for linux"
HOMEPAGE="https://github.com/shinh/maloader"

LICENSE="BSD-2 BSD APSL MIT"
SLOT="0"
IUSE="+libcxx"

DEPEND="dev-libs/opencflite >=sys-devel/llvm-3.5[clang]"
RDEPEND="${DEPEND}"

#src_configure() {
#	epatch "${FILESDIR}/${P}-path.patch"
#}

src_compile() {
	# TODO: debug flag ->use emake all
	emake release $(use libcxx && echo USE_LIBCXX=1) || die "make release failed"
	mv extract maloader-extract || die
}

src_install() {
	dolib.so libmac.so || die
	dobin maloader-extract macho2elf ld-mac || die
	dobin unpack_xcode.sh binfmt_misc.sh || die
	dodoc README || die
}
