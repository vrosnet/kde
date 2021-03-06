# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit kde5

DESCRIPTION="Framework for converting units"
LICENSE="LGPL-2+"
KEYWORDS=""
IUSE=""

RDEPEND="
	$(add_frameworks_dep ki18n)
	$(add_qt_dep qtnetwork)
	$(add_qt_dep qtxml)
"
DEPEND="${RDEPEND}"
