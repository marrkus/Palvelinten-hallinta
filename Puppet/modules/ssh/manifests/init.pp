class ssh {
	package { 'openssh-server':
		ensure => 'installed',
		allowcdrom => true,	
	}
	
	file { '/etc/ssh/sshd_config':
		content => template('ssh/sshd_config'),
		notify => Service['ssh'],
	}

	service { 'ssh':
		ensure => 'running',
		enable => true
	}
}
