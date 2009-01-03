# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

KMNAME="kdenetwork"
inherit kde4-meta

DESCRIPTION="KDE multi-protocol IM client"
KEYWORDS="~amd64 ~x86"
IUSE="debug groupwise jingle htmlhandbook ssl" 

# availible plugins
#
#	addbookmarks: NO DEPS
#	alias: NO DEPS
#	autoreplace: NO DEPS
#	contactnotes: NO DEPS
#	highlight: NO DEPS
#	history: NO DEPS
#	latex: virtual/latex as RDEPEND
#	nowlistening: NO DEPS
#	otr: libotr
#	pipes: NO DEPS
#	privacy: NO DEPS
#	statistic: dev-db/sqlite:3
#	texteffect: NO DEPS
#	translator: NO DEPS
#	urlpicpreview: NO DEPS
#	webpresence: libxml2 libxslt
# NOTE: by default we enable all plugins wich dont have any dependencies
PLUGINS="+addbookmarks +alias +autoreplace +contactnotes +highlight +history latex
+nowlistening otr +pipes +privacy +statistic +texteffect +translator +urlpicpreview webpresence"

# availible protocols
#
#	bonjour: NO DEPS
#	gadu: openssl
#	groupwise: app-crypt/qca:2
#	irc: NO DEPS, probably will fail so inform user about it
#	jabber: net-dns/libidn app-crypt/qca:2 ENABLED BY DEFAULT NETWORK 
#	meanwhile: net-libs/meanwhile
#	messenger: NO DEPS
#	msn: libmsn
#	oscar: NO DEPS
#	qq: NO DEPS
#	sms: NO DEPS
#   telepathy: net-libs/decibel
#   testbed: NO DEPS
#	winpoupup: NO DEPS
#	wlm: libmsn
#	yahoo: NO DEPS
PROTOCOLS="bonjour gadu groupwise irc +jabber meanwhile messenger msn oscar qq
testbed telepathy winpoupup wlm yahoo"

IUSE="${IUSE} ${PLUGINS} ${PROTOCOLS}"

# Tests are KDE-ish.
RESTRICT="test"

COMMONDEPEND="dev-libs/libpcre
	x11-libs/libXScrnSaver
	gadu? ( dev-libs/openssl )
	groupwise? ( app-crypt/qca:2 )
	jabber? (
		net-dns/libidn
		app-crypt/qca:2
		jingle? (
			net-libs/libjingle
			>=net-libs/ortp-0.13
			>=media-libs/speex-1.2_rc1
		)
	)
	otr? ( net-libs/libotr )
	meanwhile? ( net-libs/meanwhile )
	msn? ( net-libs/libmsn )
	statistics? ( dev-db/sqlite:3 )
	webpresence? ( dev-libs/libxml2 dev-libs/libxslt )
	wlm? ( net-libs/libmsn )"

RDEPEND="${COMMONDEPEND}
	latex? ( virtual/latex-base )
	telepathy? ( net-libs/decibel )"

DEPEND="${COMMONDEPEND}
	x11-proto/scrnsaverproto"

PDEPEND="ssl? ( app-crypt/qca-ossl )"

src_configure() {
	local x
	# Xmms isn't in portage, thus forcefully disabled.
	mycmakeargs="${mycmakeargs} -DWITH_Xmms=OFF"
	# enable protocols
	for x in ${PROTOCOLS}; do
		if [[ $x = irc ]]; then
			elog "IRC is not working yet so I only show this info instead of compiling it. Sorry"
		else
			mycmakeargs="${mycmakeargs} $(cmake-utils_use_with ${x})"
		fi
	done
	# enable plugins
	for x in ${PLUGINS}; do
		mycmakeargs="${mycmakeargs} $(cmake-utils_use_with ${x})"
	done
	# additional defines
	if use jingle && ! use jabber; then
		elog "You enabled jingle but not jabber useflag. Jingle is integral part of"
		elog "jabber protocol."
	fi
	if use jabber; then
		mycmakeargs="${mycmakeargs} -DNO_JINGLE=$(use jingle && echo OFF || echo ON)"
	fi
	kde4-meta_src_configure
}

pkg_postinst() {
	if use telepathy; then
		elog "To use kopete telepathy plugins, you need to start gabble first:"
		elog "GABBLE_PERSIST=1 telepathy-gabble &"
		elog "export TELEPATHY_DATA_PATH=/usr/share/telepathy/managers/"
	fi
	if ! use ssl; then
		if use jabber || use messenger || use irc; then
			echo
			elog "In order to use ssl in jabber, messenger and irc you'll need to"
			elog "install app-crypt/qca-ossl package."
			echo
		fi
	fi
}
