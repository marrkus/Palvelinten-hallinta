# Palvelinten-hallinta
Puppet training

Based on Configuration Management Course by Tero Karvinen. http://terokarvinen.com/2017/aikataulu-palvelinten-hallinta-ict4tn022-3-5-op-uusi-ops-loppusyksy-2017-p5

Apache2 module for Puppet:

<<<<<<< HEAD
	class apache {
        	package {"apache2":
                ensure => "installed",
        }

	file {"/var/www/html/index.html":
                content=>"Welcome\n",
        }


	service {"apache2":
                ensure=>"running",
                enable=>"true",
                require=>Package["apache2"],
=======
class apache {
        package {'apache2':
                ensure => 'installed',
        }

file {'/var/www/html/index.html':
                content=>'Welcome\n',
        }


service {'apache2':
                ensure=>'running',
                enable=>'true',
                require=>Package['apache2'],
>>>>>>> 42b1cabf0b5226c455331c8e6c4f2b7878fb476c
        }



	file { '/etc/apache2/mods-enabled/userdir.load':
                ensure => 'link',
                target => '/etc/apache2/mods-available/userdir.load',
                notify => Service['apache2'],
                require => Package['apache2'],
        }

        file { '/etc/apache2/mods-enabled/userdir.conf':
                ensure => 'link',
                target => '/etc/apache2/mods-available/userdir.conf',
                notify => Service['apache2'],
                require => Package['apache2'],
   }

}


<<<<<<< HEAD
	sudo puppet apply -e 'class {apache:}'
=======
sudo puppet apply -e 'class {apache:}'

>>>>>>> 42b1cabf0b5226c455331c8e6c4f2b7878fb476c
