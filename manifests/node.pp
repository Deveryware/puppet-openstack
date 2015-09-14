node default {
 include jenkins
}

node /^permiloc-*/ {
 include jenkins
 include dw_permiloc
 include redis
 include haproxy

 class { '::mysql::server':
  override_options => { 'mysqld' => { 'max_connections' => '3000' } } 
 }
}

node /^mpa-*/ {
 include jenkins
 include dw_mpa
 include haproxy
 include '::mongodb::server'
 include '::rabbitmq'
}

node /^mpb-*/ {
 include jenkins
 include dw_mypub
 include haproxy
 include '::mysql::server'

 class { 'elasticsearch':
  package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.7.1.deb'
 }

 elasticsearch::instance { 'es-01': }
}
