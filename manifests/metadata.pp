# Currently this only creates a _single_ metadata provider
# it will need to be modified to permit multiple metadata providers
define shibboleth::metadata(
  $provider_uri,
  $cert_uri                 = undef,
  $backing_file_dir         = $::shibboleth::conf_dir,
  $backing_file_name        = undef,
  $cert_dir                 = $::shibboleth::conf_dir,
  $cert_file_name           = undef,
  $provider_type            = 'XML',
  $provider_reload_interval = '7200',
  $metadata_filter_max_validity_interval  = '2419200'
){

  $_backing_file_name = $backing_file_name ? {
    undef => inline_template("<%= @provider_uri.split('/').last  %>"),
    default => $backing_file_name
  }

  $backing_file = "${backing_file_dir}/${_backing_file_name}"


  $_cert_file_name = $cert_file_name ? {
    undef => inline_template("<%= @cert_uri.split('/').last  %>"),
    default => $cert_file_name
  }
  $cert_file    = "${cert_dir}/${_cert_file_name}"

  if $cert_uri {
    # Get the Metadata signing certificate
    exec{"${title}::get_metadata_cert":
      path    => ['/usr/bin'],
      command => "wget ${cert_uri} -O ${cert_file}",
      creates => $cert_file,
      notify  => Service['httpd','shibd'],
    }
  }

  # This puts the MetadataProvider entry in the 'right' place
  augeas{"${title}::shib_create_metadata_provider":
    lens    => 'Xml.lns',
    incl    => $::shibboleth::config_file,
    context => "/files${::shibboleth::config_file}/SPConfig/ApplicationDefaults",
    changes => [
      'ins MetadataProvider after Errors',
    ],
    onlyif  => 'match MetadataProvider/#attribute/uri size == 0',
    notify  => Service['httpd','shibd'],
  }

  # This will update the attributes and child nodes if they change
  augeas{"${title}::shib_metadata_provider":
    lens    => 'Xml.lns',
    incl    => $::shibboleth::config_file,
    context => "/files${::shibboleth::config_file}/SPConfig/ApplicationDefaults",
    changes => [
      "set MetadataProvider/#attribute/type ${provider_type}",
      "set MetadataProvider/#attribute/uri ${provider_uri}",
      "set MetadataProvider/#attribute/backingFilePath ${backing_file}",
      "set MetadataProvider/#attribute/reloadInterval ${provider_reload_interval}",
      'set MetadataProvider/MetadataFilter[1]/#attribute/type RequireValidUntil',
      "set MetadataProvider/MetadataFilter[1]/#attribute/maxValidityInterval ${metadata_filter_max_validity_interval}",
      'set MetadataProvider/MetadataFilter[2]/#attribute/type Signature',
      "set MetadataProvider/MetadataFilter[2]/#attribute/certificate ${cert_file}",
    ],
    notify  => Service['httpd','shibd'],
    require => [Augeas["${title}::shib_create_metadata_provider"]],
  }

}
