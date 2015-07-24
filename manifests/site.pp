
## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'master.home',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# Kill deprecation warnings in PE 3.3:
Package { allow_virtual => false }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
  # include ::ntp
  include ::notifyme
}

node 'node01.home' {
  include ::notifyme
  include ::sudo
  include ::ssh
  include ::postfix
  package {'unzip':
      ensure => present,
  }
  package {'java-1.7.0-openjdk-devel':
      ensure => present,
  }
#  class {'mysql':
#      user => 'mysql',
#      service_running => false,
#      service_enabled => false,
#  }
  propuppet-apache::vhost { 'www.node01.home':
      port => '81',
      docroot => "/var/www/www.node01.home",
      ssl => false,
      priority => '12',
  } 
  propuppet-apache::vhost { 'www.xxx.home':
      port => '80',
      docroot => "/var/www/$name",
      ssl => true,
      priority => '11',
  } 
  # include ::propuppet-apache::load_balancermembers
}

node 'master.home' {
  include ::ssh
  include ::postfix
  include ::propuppet-apache::worker
  include r10k::mcollective
#  include 'docker'
#  docker::image {'jenkinsci/workflow-demo':
#      ensure => present,
#  }
}
