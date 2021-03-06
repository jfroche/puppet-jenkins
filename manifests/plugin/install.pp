# == Define: install
#
#  Install a Jenkins plugin
#
define jenkins::plugin::install($version=0) {
  $plugin     = "${name}.hpi"
  $plugin_parent_dir = '/var/lib/jenkins'
  $plugin_dir = '/var/lib/jenkins/plugins'

  if ($version != 0) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
  }
  else {
    $base_url   = 'http://updates.jenkins-ci.org/latest/'
  }

  if (!defined(File[$plugin_dir])) {
    file {
      [$plugin_dir]:
        ensure => directory,
        owner  => 'jenkins',
        group  => 'jenkins';
    }
  }

  if (!defined(User['jenkins'])) {
    user {
      'jenkins' :
        ensure => present;
    }
  }

  exec {
    "download-${name}" :
      command  => "wget --no-check-certificate ${base_url}${plugin}",
      cwd      => $plugin_dir,
      require  => File[$plugin_dir],
      path     => ['/usr/bin', '/usr/sbin',],
      user     => 'jenkins',
      unless   => "/usr/bin/test -f `echo ${plugin_dir}/${plugin}|/bin/sed 's/hpi/jpi/g'`|| /usr/bin/test -f ${plugin_dir}/${plugin}",
      notify   => Service['jenkins'];
  }
}
