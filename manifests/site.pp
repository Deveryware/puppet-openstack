filebucket { 'main': server => 'permiloc-puppet-master' }
File { backup => 'main' }
 
import "node"
