# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools eutils llvm toolchain-funcs

CCTOOLS_VERSION=839
LD64_VERSION=136
DYLD_VERSION=210.2.3
LIBUNWIND_VERSION=35.1
LIBC_VERSION=825.26
XNU_VERSION=2050.24.15

RESTRICT="test" # the test suite will test what's installed.

DESCRIPTION="Darwin assembler as(1) and static linker ld(1), Xcode Tools ${PV}"
HOMEPAGE="http://www.opensource.apple.com/darwinsource/"

SRC_URI="https://github.com/kwhat/${PN}/archive/${PV}-testing.zip
	https://www.opensource.apple.com/tarballs/cctools/cctools-${CCTOOLS_VERSION}.tar.gz
	https://www.opensource.apple.com/tarballs/ld64/ld64-${LD64_VERSION}.tar.gz
	https://www.opensource.apple.com/tarballs/dyld/dyld-${DYLD_VERSION}.tar.gz
	https://www.opensource.apple.com/tarballs/libunwind/libunwind-${LIBUNWIND_VERSION}.tar.gz
	https://www.opensource.apple.com/tarballs/Libc/Libc-${LIBC_VERSION}.tar.gz
	https://www.opensource.apple.com/tarballs/xnu/xnu-${XNU_VERSION}.tar.gz"

LICENSE="APSL-2"
SLOT="4"

KEYWORDS="~amd64 ~x86"
IUSE="lto objc"

S="${WORKDIR}"/${P}-testing

#
# The cross-compile logic
#
if [[ ${CATEGORY} == cross-* ]] ; then
	export CTARGET=${CATEGORY#cross-}
fi
is_cross() { [[ ! -z "${CTARGET}" ]] && [[ ${CHOST} != ${CTARGET} ]] ; }

DEPEND="
	dev-libs/blocks-runtime
	sys-darwin/apple-sdk:10.8
	sys-devel/llvm[gold]
	objc? ( gnustep-base/libobjc2 )"

if is_cross ; then
	DEPEND="
		${DEPEND}
		app-eselect/eselect-binutils-apple"
fi

RDEPEND="sys-devel/clang"

pkg_setup() {
	llvm_pkg_setup
}

src_unpack() {
	unpack ${A}

	cp -R "${WORKDIR}"/cctools-${CCTOOLS_VERSION}/ar "${S}" || die
	cp -R "${WORKDIR}"/cctools-${CCTOOLS_VERSION}/as "${S}" || die
	cp -R "${WORKDIR}"/cctools-${CCTOOLS_VERSION}/include "${S}" || die
	cp -R "${WORKDIR}"/cctools-${CCTOOLS_VERSION}/libstuff "${S}" || die
	cp -R "${WORKDIR}"/cctools-${CCTOOLS_VERSION}/misc "${S}" || die
	cp -R "${WORKDIR}"/cctools-${CCTOOLS_VERSION}/otool "${S}" || die

	cp -R "${WORKDIR}"/ld64-${LD64_VERSION}/src "${S}"/ld64 || die
	cp -R "${WORKDIR}"/libunwind-${LIBUNWIND_VERSION}/include/* "${S}"/ld64/src/abstraction || die
	cp -R "${WORKDIR}"/dyld-${DYLD_VERSION}/include/mach-o "${S}"/ld64/src/abstraction || die

	touch "${S}"/ld64/src/ld/configure.h || die

	mkdir "${S}"/include/i386 || die
	cp -R "${WORKDIR}"/xnu-${XNU_VERSION}/osfmk/mach/mig_errors.h "${S}"/include/mach/mig_errors.h || die
	cp -R "${WORKDIR}"/xnu-${XNU_VERSION}/bsd/i386/_types.h "${S}"/include/i386/_types.h || die

	cp "${WORKDIR}"/Libc-${LIBC_VERSION}/string/strlcpy.c "${S}"/libemulated || die
	cp "${WORKDIR}"/Libc-${LIBC_VERSION}/string/strlcat.c "${S}"/libemulated || die
	cp "${WORKDIR}"/Libc-${LIBC_VERSION}/string/FreeBSD/strmode.c "${S}"/libemulated || die

	touch "${S}"/libemulated/config.h || die
	touch "${S}"/AUTHORS "${S}"/ChangeLog "${S}"/NEWS "${S}"/README
	mv -f "${WORKDIR}"/cctools-${CCTOOLS_VERSION}/APPLE_LICENSE "${S}"/COPYING
}

src_prepare() {
	eapply_user

	# Fix private extern
	find ./ -type f -a \( -name \*.h -o -name \*.c \) -exec sed -i 's/^__private_extern__/__attribute__((visibility("hidden")))/g' {} \;

	for file in "${S}"/patches/*.patch; do
		epatch "${file}"
	done

	eautoreconf
}

src_configure() {
	econf \
		--prefix="${EPREFIX}"/usr/lib/${PN}/${PV} \
		--enable-apple-sdk="${EPREFIX}"/opt/MacOSX10.8.sdk \
		$(use_enable lto) || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	# Create chost clang scripts required for autotools.
	into /usr/lib/${PN}/${PV}

	local target=
	if is_cross ; then
		target="${CTARGET}-"
	fi

	newbin "${FILESDIR}"/cross-llvm ${target}clang
	dosym ${target}clang /usr/lib/${PN}/${PV}/bin/${target}clang++ || die

	# Fix for ld.32 support
	dosym ${target}ld.64 /usr/lib/${PN}/${PV}/bin/${target}ld || die
}

pkg_postinst() {
	if is_cross ; then
		eselect binutils-apple set ${CTARGET}-${PV}
	fi
}

pkg_postrm() {
	if is_cross ; then
		eselect binutils-apple unset ${CTARGET}-${PV}
	fi
}
