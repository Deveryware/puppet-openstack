node default {
 include resolvconf
 include jenkins
 include stack
}

node common-graylog2 {
 include resolvconf
 include jenkins
 include stack

  class { 'locales':
  locales   => ['en_US.UTF-8 UTF-8', 'fr_FR.UTF-8 UTF-8'],
 }->
 class { '::mongodb::globals':
  manage_package_repo => true,
  server_package_name => 'mongodb-org',
  version => '2.6.11',
  require => File["/etc/apt/apt.conf.d/99auth"],
 }->
 class { '::mongodb::server':
  bind_ip => ['0.0.0.0'],
 }
 
 class { 'elasticsearch':
  package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.7.1.deb',
  config => { 'cluster.name' => 'graylog2' }
 } ->
 elasticsearch::instance { 'es-01': }

 class {'graylog2::repo':
  version => '1.2.2'
 }->
 class {'graylog2::server':
  password_secret    => 'nLz2BaffxZaeGwpOcf1y1uV0VW8lk2CgzNXrr9QXTDtQgcMQzmWuUwCoHKIRWA5jhXrHjBC8MIeH5kPCLhbdJknXSb3G6Y2y',
  root_password_sha2 => '77a1559e590dbb180c272b5947e37731c9527da0f980d05e268b2d9b8a387177'
 }->
 class {'graylog2::web':
  application_secret => 'nLz2BaffxZaeGwpOcf1y1uV0VW8lk2CgzNXrr9QXTDtQgcMQzmWuUwCoHKIRWA5jhXrHjBC8MIeH5kPCLhbdJknXSb3G6Y2y',
 }

 package { "openjdk-7-jdk": ensure => "installed" }

 file { "/etc/apt/apt.conf.d/99auth":
    owner     => root,
    group     => root,
    content   => "APT::Get::AllowUnauthenticated yes;",
    mode      => 644,
  }
}

node common-rabbitmq {
 include resolvconf
 include jenkins
 include stack
 
 file { "/etc/apt/apt.conf.d/99auth":       
    owner     => root,
    group     => root,
    content   => "APT::Get::AllowUnauthenticated yes;",
    mode      => 644,
  }

  class { '::rabbitmq':
    require   => File["/etc/apt/apt.conf.d/99auth"],
  }
}

node /^permiloc-*/ {
 include resolvconf
 include jenkins
 include stack
 include dw_permiloc
 include redis
 include haproxy

 package { "openjdk-7-jdk": ensure => "installed" }

 class { '::mysql::server':
  override_options => { 'mysqld' => { 'max_connections' => '4000', 'bind-address' => '0.0.0.0' } } 
 } ->
 mysql_user { 'root@%':
  ensure => 'present'
 } ->
 mysql_grant { 'root@%/*.*':
  ensure => 'present',
  options => ['GRANT'],
  privileges => ['ALL'],
  user => 'root@%',
  table => '*.*',
 }

 file { "/etc/apt/apt.conf.d/99auth":
    owner     => root,
    group     => root,
    content   => "APT::Get::AllowUnauthenticated yes;",
    mode      => 644,
 }

 class { '::rabbitmq':
    require   => File["/etc/apt/apt.conf.d/99auth"],
 }->
 exec { 'vhost': command => '/usr/bin/sudo rabbitmqctl add_vhost permiloc', unless => '/usr/bin/sudo rabbitmqctl list_vhosts | grep -qi permiloc', }->
 exec { 'user': command => '/usr/bin/sudo rabbitmqctl add_user permiloc password', unless => '/usr/bin/sudo rabbitmqctl list_users | grep -qi permiloc', }->
 exec { 'admin': command => '/usr/bin/sudo rabbitmqctl set_user_tags permiloc administrator', }->
 exec { 'permission': command => '/usr/bin/sudo rabbitmqctl set_permissions -p permiloc permiloc ".*" ".*" ".*"', }
  
}

node /^mpa-*/ {
 include resolvconf
 include jenkins
 include stack
 include dw_mpa
 include haproxy

 class { 'locales': 
  locales   => ['en_US.UTF-8 UTF-8', 'fr_FR.UTF-8 UTF-8'],
 }-> 
 class { '::mongodb::globals':
  manage_package_repo => true,
  server_package_name => 'mongodb-org',
  version => '2.6.11',
  require => File["/etc/apt/apt.conf.d/99auth"],
 }->
 class { '::mongodb::server': 
  bind_ip => ['0.0.0.0'],
 }

 package { "openjdk-7-jdk": ensure => "installed" }

 file { "/etc/apt/apt.conf.d/99auth":
    owner     => root,
    group     => root,
    content   => "APT::Get::AllowUnauthenticated yes;",
    mode      => 644,
 }

 class { '::rabbitmq':
    require   => File["/etc/apt/apt.conf.d/99auth"],
 }->
 exec { 'vhost': command => '/usr/bin/sudo rabbitmqctl add_vhost mpa', unless => '/usr/bin/sudo rabbitmqctl list_vhosts | grep -qi mpa', }->
 exec { 'user': command => '/usr/bin/sudo rabbitmqctl add_user mpa password', unless => '/usr/bin/sudo rabbitmqctl list_users | grep -qi mpa', }->
 exec { 'admin': command => '/usr/bin/sudo rabbitmqctl set_user_tags mpa administrator', }->
 exec { 'permission': command => '/usr/bin/sudo rabbitmqctl set_permissions -p mpa mpa ".*" ".*" ".*"', }
}

node /^mpb-*/ {
 include resolvconf
 include jenkins
 include stack
 include dw_mypub
 include haproxy
 class { '::mysql::server':
  override_options => { 'mysqld' => { 'max_connections' => '5000', 'bind-address' => '0.0.0.0', 'character-set-server' => 'utf8' }, 'mysql' => { 'default-character-set' => 'utf8' }, 'client' => { 'default-character-set' => 'utf8' } }
 }

 package { "openjdk-7-jdk": ensure => "installed" }

 class { 'elasticsearch':
  package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.7.1.deb'
 } ->
 elasticsearch::instance { 'es-01': }
}
