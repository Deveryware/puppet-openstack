class resolvconf {
	file {'/etc/resolv.conf':
		content => 'nameserver 192.168.10.30'
	}
}
