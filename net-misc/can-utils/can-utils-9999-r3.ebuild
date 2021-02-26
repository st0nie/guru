# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://github.com/linux-can/${PN}.git"
EGIT_BRANCH="master"

inherit autotools git-r3 systemd

DESCRIPTION="CAN userspace utilities and tools"
HOMEPAGE="https://github.com/linux-can/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"

DEPEND=""

src_prepare() {
	eautoreconf
}

# Default src_install + newconfd and newinitd
src_install() {

	emake DESTDIR="${D}" install

	if ! declare -p DOCS >/dev/null 2>&1 ; then
		local d
		for d in README* ChangeLog AUTHORS NEWS TODO CHANGES THANKS BUGS \
				FAQ CREDITS CHANGELOG ; do
			[[ -s "${d}" ]] && dodoc "${d}"
		done
	elif declare -p DOCS | grep -q "^declare -a " ; then
		dodoc "${DOCS[@]}"
	else
		dodoc ${DOCS}
	fi

	if use systemd ; then
		systemd_dounit "${FILESDIR}/slcan.service"
		systemd_install_serviced "${FILESDIR}/slcan.service.conf"
	else
		newconfd "${FILESDIR}/slcand.confd" slcand
		newinitd "${FILESDIR}/slcand.initd" slcand
	fi
}
