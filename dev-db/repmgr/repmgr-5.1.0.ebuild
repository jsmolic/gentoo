# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="PostgreSQL Replication Manager"
HOMEPAGE="http://www.repmgr.org/"
SRC_URI="http://www.repmgr.org/download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-db/postgresql:*[server,static-libs]"
RDEPEND="${DEPEND}
	net-misc/rsync"

PATCHES=( "${FILESDIR}"/${P}-fno-common.patch )

src_compile() {
	emake USE_PGXS=1
}

src_install() {
	emake DESTDIR="${D}" USE_PGXS=1 install
	export PGSLOT="$(postgresql-config show)"
	einfo "PGSLOT: ${PGSLOT}"

	PGBASEDIR="${EPREFIX}"/usr/$(get_libdir)/postgresql-${PGSLOT}
	PGBINDIR="${PGBASEDIR}"/bin
	PGCONTRIB="${EPREFIX}"/usr/share/postgresql-${PGSLOT}/contrib/

	dodir ${PGCONTRIB} ${PGBINDIR}

	local repmgr="usr/bin/repmgr${PGSLOT//.}"
	local repmgrd="usr/bin/repmgrd${PGSLOT//.}"
	dosym ${PGBINDIR}/repmgr "${repmgr}"
	dosym ${PGBINDIR}/repmgrd "${repmgrd}"

	dodoc  CREDITS HISTORY COPYRIGHT *.md
	insinto /etc
	newins repmgr.conf.sample repmgr.conf

	fowners postgres:postgres /etc/repmgr.conf
	ewarn "Remember to modify /etc/repmgr.conf"
}
