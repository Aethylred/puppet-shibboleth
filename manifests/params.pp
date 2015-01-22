# Class: shibboleth::params
#
# This class manages shared prameters and variables for the shibboleth module
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

# [Remember: No empty lines between comments and class definition]
class shibboleth::params {

  $admin              = $::apache::serveradmin
  $hostname           = $::fqdn
  $logo_location      = '/shibboleth-sp/logo.jpg'
  $style_sheet        = '/shibboleth-sp/main.css'
  $conf_dir           = '/etc/shibboleth'
  $conf_file          = 'shibboleth2.xml'
  $sp_cert            = 'sp-cert.pem'
  $bin_dir            = '/usr/sbin'
  $discovery_protocol = 'SAMLDS'

  case $::osfamily {
    'Debian':{
      $user  = '_shibd'
      $group = '_shibd'
    }
    'RedHat':{
      # Do nothing
    }
    default:{
      fail("The shibboleth Puppet module does not support ${::osfamily} family of operating systems")
    }
  }
}
