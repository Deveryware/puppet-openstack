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

 class { '::mysql::server':
  override_options => { 'mysqld' => { 'max_connections' => '3000' } } 
 }
}

node /^mpa-*/ {
 include resolvconf
 include jenkins
 include stack
 include dw_mpa
 include haproxy
 include '::mongodb::server'

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

 class { 'elasticsearch':
  package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.7.1.deb'
 }

 elasticsearch::instance { 'es-01': }
}
