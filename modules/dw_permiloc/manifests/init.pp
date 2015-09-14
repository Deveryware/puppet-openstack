class dw_permiloc {

	user {'dw_permiloc':
		comment => 'dw_permiloc account',
		managehome => 'true',
                ensure => 'present',
                shell => '/dev/null',
                home => '/srv/dw_permiloc'
        }

	file {'/etc/security/limits.conf':
		ensure => 'present',
		content => '* - nofile 65536'
	}

	package {'python-mysqldb':
		ensure => 'installed'
	}
}
