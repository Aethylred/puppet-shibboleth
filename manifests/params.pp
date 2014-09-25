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

  case $::osfamily {
    Debian:{
      # Do nothing
    }
    default:{
      fail("The shibboleth Puppet module does not support ${::osfamily} family of operating systems")
    }
  }
}
