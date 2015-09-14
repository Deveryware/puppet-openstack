class dw_mypub {

	user {'dw_mypub':
		comment => 'dw_mypub account',
		managehome => 'true',
                ensure => 'present',
                shell => '/dev/null',
                home => '/home/dw_mypub'
        }

	file {'/etc/security/limits.conf':
		ensure => 'present',
		content => '* - nofile 65536'
	}

	package {'python-mysqldb':
                ensure => 'installed'
        }
}
