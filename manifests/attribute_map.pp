# parameter setup allows an attribute_map to bedownloaded with one name
# and saved locally by another.
define shibboleth::attribute_map(
  $map_uri,
  $map_dir  = $::shibboleth::conf_dir,
  $max_age  = '21'
){

  $attribute_map = "${map_dir}/${name}.xml"

  # Download the attribute map, refresh after $max_age days
  exec{"get_${name}_attribute_map":
    path    => ['/usr/bin'],
    command => "wget ${map_uri} -O ${attribute_map}",
    unless  => "test `find ${attribute_map} -mtime +${max_age}`",
    notify  => Service['httpd','shibd'],
  }

  # Make sure the shibboleth config is pointing at the attribute map
  augeas{"shib_${name}_attribute_map":
    lens    => 'Xml.lns',
    incl    => $::shibboleth::config_file,
    context => "/files${::shibboleth::config_file}/SPConfig/ApplicationDefaults",
    changes => [
      "set AttributeExtractor/#attribute/path ${name}.xml",
    ],
    notify  => Service['httpd','shibd'],
    require => Exec["get_${name}_attribute_map"],
  }

}