# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

#LIBUNWIND=libunwind-30
#DYLD=dyld-195.6
# http://lists.apple.com/archives/Darwin-dev/2009/Sep/msg00025.html
#UNWIND=binutils-apple-3.2-unwind-patches-5

HOMEPAGE="https://github.com/kwhat/crossdev-apple-overlay/"
DESCRIPTION="Virtual for the Darwin assembler as(1) and static linker ld(1)"
SRC_URI=""

LICENSE=""
SLOT=0

KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="sys-devel/llvm[clang]
	=sys-devel/cctools-839
	=sys-devel/ld64-134.9"
RDEPEND="${DEPEND}"
