# Copyright 2013 Zuercher Hochschule fuer Angewandte Wissenschaften
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

# == Class: savanna
#
# Installs the savanna backend.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*savanna_host*]
# The host on which the savanna process (API) runs. Defaults to '127.0.0.1'
# [*savanna_port*]
# The port on which the savanna process (API) runs on. Defaults to 3836
# [*db_host*]
# The host where the database is running. Savanna will use this to persist
# information about clusters. Defaults to '127.0.0.1'
# [*savanna_db_name*]
# [*savanna_db_password*]
# [*keystone_auth_protocol*]
# Defaults to 'http',
# [*keystone_auth_host*]
# Defaults to '127.0.0.1'
# [*keystone_auth_port*]
# Defaults to '35357'
# [*keystone_user*]
# Defaults to 'savanna'
# [*keystone_password*]
# Defaults to 'savanna'
# [*keystone_tenant*]
# Defaults to undef
# [*savanna_verbose*]
# Defaults to false
# [*savanna_debug*]
# Defaults to false
# === Examples
#
# class{'savanna':
#   savanna_host              => '127.0.0.1',
#   db_host                   => '127.0.0.1',
#   savanna_db_password       => 'savanna',
#   keystone_auth_host        => '127.0.0.1',
#   keystone_password         => 'admin',
#   savanna_verbose           => True,
#}
#
# === Authors
#
# Andy Edmonds <andy@edmonds.be>
#
#
# TODOs
# - need to install disk builder and create image
#   or generate and install
# - use a puppet type for configuration file
# - clean up documentation

class savanna (
  $savanna_host           = '127.0.0.1',
  $savanna_port           = '8386',
  $savanna_verbose        = false,
  $savanna_debug          = false,
  # db
  $db_host                = '127.0.0.1',
  $savanna_db_name        = 'savanna',
  $savanna_db_user        = 'savanna',
  $savanna_db_password    = 'savanna',
  # keystone
  $keystone_host          = '127.0.0.1',
  $keystone_port          = '35357',
  $keystone_protocol      = 'http',
  $keystone_user          = 'savanna',
  $keystone_tenant        = 'services',
  $keystone_password      = 'savanna',
  $use_neutron            = false,
  $use_floating_ips       = true,
  $node_domain            = 'novalocal',
  $plugins                = 'vanilla,hdp,idh',
  $debug                  = false,
  $verbose                = false,
  {
  include savanna::params

  if !$keystone_tenant {
    $int_keystone_tenant = $keystone_user
  } else {
    $int_keystone_tenant = $keystone_tenant
  }

  if $use_neutron {
    $use_neutron_value = true
  } else {
    $use_neutron_value = false
  }

  if $use_floating_ips {
    $use_floating_ips_value = true
  } else {
    $use_floating_ips_value = false
  }

  class { '::savanna::install':
  } ->
  class { '::savanna::service': }
  
  savanna_config {
    'DEFAULT/os_admin_tenant_name'         : value => $keystone_tenant;
    'DEFAULT/os_admin_username'            : value => $keystone_user;
    'DEFAULT/os_admin_password'            : value => $keystone_password;
    'DEFAULT/os_auth_host'                 : value => $keystone_host;
    'DEFAULT/os_auth_port'                 : value => $keystone_port;
    'DEFAULT/use_floating_ips'             : value => $use_floating_ips_value;
    'DEFAULT/use_neutron'                  : value => $use_neutron_value;
    'DEFAULT/node_domain'                  : value => $node_domain;
    'DEFAULT/plugins'                      : value => $plugins;
    'database/connection'                  : value => $sql_connection;
    'database/max_retries'                 : value => '-1';
    'DEFAULT/verbose'                      : value => $verbose;
    'DEFAULT/debug'                        : value => $debug;
  }
}
