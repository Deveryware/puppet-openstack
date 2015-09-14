class jenkins {
	user {'jenkins':
		comment => 'jenkins account',
		managehome => 'true',
		ensure => 'present',
		shell => '/bin/bash',
		home => '/home/jenkins'
	}
	
	file {'/etc/sudoers.d/jenkins':
		ensure => 'present',
		content => 'jenkins    ALL = (ALL) NOPASSWD: ALL',
		owner => 'root',
		group => 'root'
	}

	file { '/home/jenkins/.ssh':
    		ensure => 'directory',
		mode => '0700',
		owner => 'jenkins',
		group => 'jenkins'
	}
	
	file{'/home/jenkins/.ssh/authorized_keys':
		ensure => 'present',
		owner => 'jenkins',
		group => 'jenkins',
		mode => '0600',
		source => 'puppet:///modules/jenkins/authorized_keys'
	}			
}
