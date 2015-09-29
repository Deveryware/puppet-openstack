node default {
 include resolvconf
 include jenkins
 include stack
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
  override_options => { 'mysqld' => { 'max_connections' => '3000', 'bind-address' => '0.0.0.0' } } 
 }

 mysql_user { 'root@%':
  ensure => 'present'
 }

 mysql_grant { 'root@%':
  ensure => 'present',
  options => ['GRANT'],
  privileges => ['ALL'],
  user => 'root@%'
 }
 
}

node /^mpa-*/ {
 include resolvconf
 include jenkins
 include stack
 include dw_mpa
 include haproxy

 class { '::mongodb::globals':
  manage_package_repo => true,
  server_package_name => 'mongodb-org',
  version => '2.6.11'
 }->
 class { '::mongodb::server': }

 package { "openjdk-7-jdk": ensure => "installed" }

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

node /^mpb-*/ {
 include resolvconf
 include jenkins
 include stack
 include dw_mypub
 include haproxy
 include '::mysql::server'

 package { "openjdk-7-jdk": ensure => "installed" }

 class { 'elasticsearch':
  package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.7.1.deb'
 }

 elasticsearch::instance { 'es-01': }
}
