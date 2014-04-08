# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit autotools eutils toolchain-funcs

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

DESCRIPTION="Darwin assembler as(1)"
# See: https://code.google.com/p/ios-toolchain-based-on-clang-for-linux/
HOMEPAGE="http://www.opensource.apple.com"
SRC_URI="http://www.opensource.apple.com/tarballs/cctools/${CCTOOLS}.tar.gz
	http://www.opensource.apple.com/tarballs/ld64/${LD64}.tar.gz
	http://download.gna.org/gnustep/libobjc2-1.6.1.tar.bz2
	mirror://gentoo/${P}-autotools.tar.gz
	mirror://gentoo/${P}-headers.tar.gz
	mirror://gentoo/${P}-ld64-extras.tar.gz"

LICENSE="APSL-2"

if is_cross; then
	SLOT="${CTARGET}-839"
else
	SLOT="839"
fi


KEYWORDS="x86 amd64"
#IUSE="objc++"
IUSE=""

DEPEND="sys-devel/llvm[clang]"
RDEPEND=""

#DEPEND="objc++? ( sys-devel/gcc[objc++] )
#       !objc++? ( sys-devel/gcc )"
#RDEPEND=""

S=${WORKDIR}/${P/-apple/}

BINPATH=/usr/${CHOST}/${CTARGET}/${PN}-bin/${PV}
LIBPATH=/usr/$(get_libdir)/odcctools/${CTARGET}/${PV}
DATAPATH=/usr/share/odcctools-data/${CTARGET}/${PV}

pkg_setup() {
	if ! is_cross ; then 
		eerror "Please set your CTARGET variable to the build target."
		eerror "\tEx: i686-apple-darwin9"
		die
	fi
}

src_unpack() {
	unpack ${P/-apple/}.tar.gz
	unpack ${LD64}.tar.gz
	unpack libobjc2-1.6.1.tar.bz2

	cd ${S}
	cp -rvf ../${LD64} ld64 || die
	cp -rvf ../libobjc2-1.6.1 libobjc2 || die

	unpack ${P}-autotools.tar.gz
	unpack ${P}-headers.tar.gz

	cd ${S}/ld64
	unpack ${P}-ld64-extras.tar.gz
}

src_prepare() {
	einfo "Removing unnecessary files"
	rm -rvf ${S}/{cbtlibs,dyld,file,gprof,libdyld,mkshlib,profileServer,cctools-839,efitools,PB.project,RelNotes,libmacho}
	rm -rvf ${S}/ld64/{ld64-134.9,ld64.xcodeproj,unit-tests}
	rm -rvf ${S}/libobjc2/{GNUmakefile,Makefile*}

	einfo "Removing #import"
	find ${DIST_DIR} -type f -name \*.[ch] | xargs sed -i 's/^#import/#include/g' || die

	einfo "Removing __private_extern__"
	find ${DIST_DIR} -type f -name \*.h | xargs sed -i 's/^__private_extern__/extern/g' || die

	epatch ${FILESDIR}/${P}-ar.patch
	epatch ${FILESDIR}/${P}-as.patch
	epatch ${FILESDIR}/${P}-include.patch
	epatch ${FILESDIR}/${P}-libstuff.patch
	epatch ${FILESDIR}/${P}-misc.patch
	epatch ${FILESDIR}/${P}-otool.patch

	epatch ${FILESDIR}/${P}-ld64.patch
	epatch ${FILESDIR}/${P}-libobjc2.patch

	cp APPLE_LICENSE COPYING || die
	touch AUTHORS ChangeLog NEWS README || die

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
			dosym "${D}"usr/libexec/gcc/${CTARGET}/"$(basename "${item}" | sed -e "s/${CTARGET}-//")" /usr/bin/${CTARGET}-$(basename "${item}") || die
	done
}
