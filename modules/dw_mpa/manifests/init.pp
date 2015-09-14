class dw_mpa {

	user {'dw_mpa':
		comment => 'dw_mpa account',
		managehome => 'true',
                ensure => 'present',
                shell => '/dev/null',
                home => '/srv/dw_mpa'
        }

	file {'/etc/security/limits.conf':
		ensure => 'present',
		content => '* - nofile 65536'
	}
}
