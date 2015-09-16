class stack {
	user {'stack':
		comment => 'stack account',
		managehome => 'true',
		ensure => 'present',
		shell => '/bin/bash',
		home => '/home/stack'
	}
	
	file { '/home/stack/.ssh':
    		ensure => 'directory',
		mode => '0700',
		owner => 'stack',
		group => 'stack'
	}
	
	file{'/home/stack/.ssh/authorized_keys':
		ensure => 'present',
		owner => 'stack',
		group => 'stack',
		mode => '0600',
		source => 'puppet:///modules/stack/authorized_keys'
	}			
}
