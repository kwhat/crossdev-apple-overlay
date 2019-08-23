# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit git-r3

SRC_URI=""
#KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
KEYWORDS=""
EGIT_REPO_URI="https://github.com/kwhat/crossdev-apple.git"

DESCRIPTION="Gentoo Cross-toolchain generator with support for apple toolchains"
HOMEPAGE="https://www.gentoo.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND=">=sys-apps/portage-2.1
	app-shells/bash
	!sys-devel/crossdev-wrappers"
DEPEND="app-arch/xz-utils"

src_install() {
	default
	if [[ "${PV}" == "99999999" ]] ; then
		sed -i "s:@CDEVPV@:${EGIT_VERSION}:" "${ED}"/usr/bin/crossdev || die
	fi
}
