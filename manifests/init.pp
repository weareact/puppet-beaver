# == Class: beaver
#
# This class is able to install or remove beaver on a node.
# It manages the status of the related service.
#
#
#
# === Parameters
#
# [*package_name*]
#   String (or Array). Controls if the name of the package.
#   Defaults to <tt>[ 'beaver' ]</tt>.
#
# [*package_ensure*]
#   String. Controls if the package shall be <tt>present</tt>,
#   <tt>absent</tt>, <tt>latest</tt>, or a specific <tt>version</tt>
#   Defaults to <tt>present</tt>.
#
# [*service_name*]
#   String. Controls if the name of the service.
#   Defaults to <tt>beaver</tt>.
#
# [*service_ensure*]
#   String. Controls if the service shall be <tt>running</tt>,
#   <tt>stopped</tt>.
#   Defaults to <tt>running</tt>.
#
# [*service_enable*]
#   Bool. Controls if the service shall be enabled (<tt>true</tt>),
#   or disabled (<tt>false</tt>).
#   Defaults to <tt>true</tt>.
#
# [*service_hasstatus*]
#   Bool. Controls if the service has a status check (<tt>true</tt>),
#   or not (<tt>false</tt>). This is platform dependent.
#   Defaults to <tt>true</tt>.
#
# [*service_hasrestart*]
#   Bool. Controls if the service can be restarted (<tt>true</tt>),
#   or not (<tt>false</tt>). This is platform dependent.
#   Defaults to <tt>true</tt>.
#
# [*service_pattern*]
#   String. Controls the pattern which to search for, if the service cannot be
#   restarted through the service, but has to be "killed".
#   Defaults to <tt>beaver</tt>.
#
# [*format*]
#   format to transfer in
#   Value can be any of: "json", "repack", "string"
#   Default value: "json"
#   This variable is optional
#
# [*respawn_delay*]
#   Delay for respawning the output thread
#   Value type is number
#   Default value: 3
#   This variable is optional
#
# [*max_failure*]
#   Number of times the respawn of an output thread is done
#   Value type is number
#   Default value: 7
#   This variable is optional
#
# [*hostname*]
#   Name to use in the @source_host variable.
#   Value type is string
#   Default value: FQDN
#   This variable is optional
#
# [*transport*]
#  Transport method to use
#  Value can be any of: "redis", "rabbitmq", "zeromq", "udp"
#  Default value: "redis"
#  This variable is optional
#
# === Examples
#
# * Installation, make sure service is running and will be started at boot time:
#     class { 'beaver': }
#
# * Removal/decommissioning:
#     class { 'beaver':
#       package_ensure => 'absent',
#       service_ensure => 'stopped',
#       service_enable => false,
#     }
#
# * Install everything but disable service(s) afterwards
#     class { 'beaver':
#       service_ensure => 'stopped',
#     }
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class beaver(
  $package_name       = $beaver::params::package_name,
  $package_ensure     = $beaver::params::package_ensure,

  $service_ensure     = $beaver::params::service_ensure,
  $service_enable     = $beaver::params::service_enable,
  $service_name       = $beaver::params::service_name,
  $service_provider   = $beaver::params::service_provider,
  $service_hasstatus  = $beaver::params::service_hasstatus,
  $service_hasrestart = $beaver::params::service_hasrestart,
  $service_pattern    = $beaver::params::service_pattern,

  $format             = $beaver::params::format,
  $respawn_delay      = $beaver::params::respawn_delay,
  $max_failure        = $beaver::params::max_failure,
  $queue_timeout      = $beaver::params::queue_timeout,
  $hostname           = $beaver::params::hostname,
  $transport          = $beaver::params::transport,
  $logstash_version   = $beaver::params::logstash_version,
  $virtualenv         = $beaver::params::virtualenv,
) inherits beaver::params {

  #### Validate parameters

  # n.b.: \d+\.\d+\.\d+ is specific to beaver, which has a very simple versioning scheme
  validate_re($package_ensure, '^(present|absent|latest|\d+\.\d+\.\d+)$')

  validate_re($service_ensure, '^(running|stopped)$')
  validate_re($service_provider, '^(init|systemd)$')

  validate_re($format, '^(json|msgpack|string|raw)$')
  validate_re($transport, '^(redis|rabbitmq|zmq|udp|mqtt|sqs)$')
  validate_re($respawn_delay, '^\d+$')
  validate_re($queue_timeout, '^\d+$')
  validate_re($logstash_version, '^(0|1)$')
  validate_re($max_failure, '^\d+$')
  validate_bool($service_enable)
  validate_string($hostname)

  $config = "logstash_version: ${logstash_version}\nhostname: ${hostname}\nformat: ${format}\nrespawn_delay: ${respawn_delay}\nmax_failure: ${max_failure}\nqueue_timeout: ${queue_timeout}\ntransport: ${transport}"

  anchor {'beaver::end': } ->
  class { 'beaver::package': } ->
  class { 'beaver::config': } ~>
  class { 'beaver::service': } ->
  anchor {'beaver::begin': }
}
