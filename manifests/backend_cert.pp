# This generates a self signed x509 certificate used to secure connections
# with a Shibboleth Federation registry. If the key is ever lost or overwritten
# the certificate will have to be re-registered.
# Alternativly, the certificate could be deployed from the puppetmaster
class shibboleth::backend_cert(
  $sp_hostname    = $shibboleth::hostname
) inherits shibboleth::params {

  require shibboleth

  $sp_cert_file = "${::shibboleth::conf_dir}/${::shibboleth::sp_cert}"

  exec{"shib_keygen_${sp_hostname}":
    path    => [$::shibboleth::bin_dir,'/usr/bin','/bin'],
    command => "shib-keygen -f -h ${sp_hostname} -e https://${sp_hostname}/shibbloeth",
    unless  => "openssl x509 -noout -in ${sp_cert_file} -issuer|grep ${sp_hostname}",
  }
}