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


CCTOOLS=cctools-839
LD64=ld64-134.9
LIBOBJC2_FILE=libobjc2-1.6.1.tar.bz2

#LIBUNWIND=libunwind-30
#DYLD=dyld-195.6
# http://lists.apple.com/archives/Darwin-dev/2009/Sep/msg00025.html
#UNWIND=binutils-apple-3.2-unwind-patches-5

# See: https://code.google.com/p/ios-toolchain-based-on-clang-for-linux/
HOMEPAGE="http://www.opensource.apple.com"
DESCRIPTION="Darwin assembler as(1) and static linker ld(1), Xcode Tools"
EGIT_REPO_URI="git://github.com/kwhat/${PN/-apple/}.git"
EGIT_BRANCH="linux-${PV}"

LICENSE="APSL-2"

if is_cross; then
	SLOT="${CTARGET}-839"
else
	SLOT="839"
fi


KEYWORDS="x86 amd64"
#IUSE="objc++"
IUSE=""

DEPEND="sys-devel/llvm[clang]
	gnustep-base/libobjc2"
RDEPEND=""

#DEPEND="objc++? ( sys-devel/gcc[objc++] )
#       !objc++? ( sys-devel/gcc )"
#RDEPEND=""

S=${WORKDIR}/${P/-apple/}

BINPATH=/usr/${CHOST}/${CTARGET}/${PN}-bin/${PV}
LIBPATH=/usr/$(get_libdir)/odcctools/${CTARGET}/${PV}
DATAPATH=/usr/share/${PN}/${CTARGET}/${PV}

pkg_setup() {
	if ! is_cross ; then 
		eerror "Please set your CTARGET variable to the build target."
		eerror "\tEx: i686-apple-darwin9"
		die
	fi
}

src_prepare() {
	eautoreconf
}

src_configure() {
	CC=clang \
	CXX=clang++ \
	econf \
		--prefix=/usr \
		--target=${CTARGET} \
		|| die
}

src_install() {
	emake DESTDIR="${D}" install || die

	# Dirty hack to put files in the correct location.
	mkdir -vp "${D}"usr/${CHOST}/${CTARGET}/${PN}/${PV}/

	# Move all files out of /usr/bin
	for item in "${D}"usr/bin/* ; do
		mv -v "${item}" "${D}"usr/${CHOST}/${CTARGET}/${PN}/${PV}/$(basename "${item}") || die
	done

	for item in "${D}"usr/${CHOST}/${CTARGET}/${PN}/${PV}/* ; do
		[[ -x ${item} ]] && \
			dosym "${item}" /usr/libexec/gcc/${CTARGET}/$(basename "${item}" | sed -e "s/${CTARGET}-//") && \
			dosym "${D}"usr/libexec/gcc/${CTARGET}/"$(basename "${item}" | sed -e "s/${CTARGET}-//")" /usr/bin/$(basename "${item}") || die
	done
}
