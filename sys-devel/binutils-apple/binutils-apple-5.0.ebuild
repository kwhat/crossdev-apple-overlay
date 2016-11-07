# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit autotools eutils git-2 toolchain-funcs

RESTRICT="test" # the test suite will test what's installed.

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} = ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi
is_cross() { [[ ${CHOST} != ${CTARGET} ]] ; }

# See: https://code.google.com/p/ios-toolchain-based-on-clang-for-linux/
HOMEPAGE="http://www.opensource.apple.com"
DESCRIPTION="Darwin assembler as(1) and static linker ld(1)"
EGIT_REPO_URI="git://github.com/kwhat/${PN}.git"
EGIT_BRANCH="${PV}"

LICENSE="APSL-2"
SLOT="5"

KEYWORDS="~x86 ~amd64"
#IUSE="objc++"
IUSE=""

DEPEND="sys-devel/dsymutil-apple
	sys-devel/llvm[clang]
	gnustep-base/libobjc2"
RDEPEND=""

#DEPEND="objc++? ( sys-devel/gcc[objc++] )
#       !objc++? ( sys-devel/gcc )"
#RDEPEND=""

S=${WORKDIR}/${P/-apple/}

BINPATH=usr/${CHOST}/${CTARGET}/${PN}/${PV}/
#LIBPATH=usr/$(get_libdir)/odcctools/${CTARGET}/${PV}
#DATAPATH=usr/share/${PN}/${CTARGET}/${PV}

pkg_setup() {
	if ! is_cross ; then
		die "Invalid configuration; do not emerge this directly"
	fi
}

src_prepare() {
	eautoreconf
}

src_configure() {
	CC=clang \
	CXX=clang++ \
	econf --prefix=/usr || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	# I have no idea what these are, testing needed.
	rm -Rv "${D}"usr/libexec/as

	# Dirty hack to put files in the correct location.
	mkdir -vp "${D}"${BINPATH}

	# Move all files out of /usr/bin
	for item in "${D}"usr/bin/* ; do
		mv -v "${item}" "${D}"${BINPATH}$(basename "${item}") || die
	done

	for item in "${D}"${BINPATH}* ; do
		[[ -x ${item} ]] && \
			dosym "${item}" /usr/libexec/gcc/${CTARGET}/$(basename "${item}" | sed -e "s/${CTARGET}-//") && \
			dosym "${D}"usr/libexec/gcc/${CTARGET}/"$(basename "${item}" | sed -e "s/${CTARGET}-//")" /usr/bin/$(basename "${item}") || die
	done
}
