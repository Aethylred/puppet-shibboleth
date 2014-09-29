# Shibboleth

[Shibboleth](http://shibboleth.net/) is among the world's most widely deployed federated identity solutions, connecting users to applications both within and between organizations. Every software component of the Shibboleth system is free and open source.

Shibboleth is an open-source project that provides Single Sign-On capabilities and allows sites to make informed authorization decisions for individual access of protected on-line resources in a privacy-preserving manner.

# The Shibboleth Puppet Module

The Shibboleth Puppet module is intended as a companion module to the [PuppetLabs Apache module](https://forge.puppetlabs.com/puppetlabs/apache) that manages the Shibboleth services used by Service Providers (SP) and Identity Providers (IDp) in a manner consistent and compatible with the usage of the Puppetlabs Apache Module. Once this module is installed and configured it should just be a matter of specifying `authType shibboleth` in an Apache Virtual Host declaration.

These shibboleth services are tightly bound to the installation of the Shibboleth Apache module `mod_shib` so the resources provided in this module are dependent on the use of the `apache::mod::shib` class from the PuppetLabs Apache module.

# Example Usage

The following is an example installation:

```puppet
# Set up Apache
class{'apache': }
class{'apache::mod::shib': }

# Initialise Shibboleth configuration and services
class{'shibboleth': }

# Set up the Shibboleth Single Sign On (sso) module
shibboleth::sso{'federation_directory':
  discoveryURL  => 'https://example.federation.org/ds/DS',
}

shibboleth::metadata{'federation_metadata':
  provider_uri  => 'https://example.federation.org/metadata/fed-metadata-signed.xml',
  cert_uri      => 'http://example.federation.org/metadata/fed-metadata-cert.pem',
}

shibboleth::attribute_map{'federation_attribute_map':
  attribute_map_uri => 'https://example.federation.org/download/attribute-map.xml',
}

include shibboleth::backend_cert
```

## Example Usage Breakdown

The following sections describe the sequence given in the Example Usage

### Apache and Shibboleth

```puppet
# Set up Apache
class{'apache': }
class{'apache::mod::shib': }
```

Setting up the `apache` class from the PuppetLabs Apache Module is a requirement, no extra configuration is required, though it is recommended that the `serveradmin` parameter is set.

This is followed by installing the Shibboleth module (`mod_shib`) for Apache. This provides the absolute minimum installation. It is `apache::mod::shib` that installs the required packages for Shibboleth and the `shibd` service.

**Note:** There are no packages for Shibboleth provided for RedHat distributions in their default repositories. A [suitable repository](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPLinuxRPMInstall) must be provided.

## Initialise Shibboleth configuration and services

```puppet
class{'shibboleth': }
```

This sets up the Shibboleth configuration, and maintains the `shibd` service.

## Configure Single Sign On with a Discovery Service

```puppet
# Set up the Shibboleth Single Sign On (SSO) module
shibboleth::sso{'federation_directory':
  discoveryURL  => 'https://example.federation.org/ds/DS',
}
```

This snippet sets up a Single Sign On (SSO) service that uses a Directory Service to handle multiple federated Identity Providers (IDp). 

*Note:* The URL is an example only, the Federation should provide the correct URL to use for its directory service.

*Note:* Alternatively if only a single IDp is to be used, use the `idpURL` parameter instead. The `idpURL` and `discoveryURL` parameters are mutually exclusive, the SSO can only use one or the other.

## Federation Metadata and Certificate

```
shibboleth::metadata{'federation_metadata':
  provider_uri  => 'https://example.federation.org/metadata/fed-metadata-signed.xml',
  cert_uri      => 'http://example.federation.org/metadata/fed-metadata-cert.pem',
}
```

Currently `shibboleth::metadata` only supports a single metadata provider, but it is possible to configure Shibboleth to use multiple metadata in a co-federated environment, hence this has been defined as a resource to permit multiple declarations. This resource requires two URIs, one to obtain the Federation metadata XML file, and another to obtain the Federation metadata signing certificate.

# Updating the Attribute map

```puppet
shibboleth::attribute_map{'federation_attribute_map':
  attribute_map_uri => 'https://example.federation.org/download/attribute-map.xml',
}
```

This is optional, and will allow `mod_shib` to use a customised attribute map downloaded from the provided URI. By default this is updated every 21 days. The parameter `max_age` can be used to set the number of days between updates.

# Create the Back-end x509 Certificate

```
include shibboleth::backend_cert
```

This creates a self signed back-end x509 certificate and key with which this Service Provider can be registered with a Federation. This method currently just runs the `shib-keygen` command with the values supplied by the `shibboleth` declaration. This certificate will be regenerated on a new deployment unless it has been saved or backed up.

It is recommended that rather than use this class, a specified certificate is deployed by Puppet from a private file server, or using a suitable x509 certificate management Puppet Module. Maintaining the back-end certificate is important as this is how a Service Provider identifies itself to other Shibboleth services.

The following snippet uploads a certificate, and uses parameters to configure Shibboleth to use it:

```puppet
class{'apache':
  servername => 'example.com'
}

class{'apache::mod::shib: '}

file{'/etc/shibboleth/example.com.crt':
  ensure => 'file'
  source => 'puppet:///private/example.com.crt'
}

class{'shibboleth':
  sp_cert  => 'example.com.crt'
}
```

# Classes and Resources

The `shibboleth` module provides the following classes and resource definitions:

## Class: `shibbloleth`

### Parameters for `shibbloleth`

* `admin`      Sets the Shibboleth administrator's email address, defaults to `apache::serveradmin`
* `hostname`   Sets the host name to be used in the Shibboleth configuration, defaults to `fqdn`
* `logoLocation`    Sets the location relative to the web root of the 'logo' to be used on error pages, defaults to `/shibboleth-sp/logo.jpg`
* `styleSheet`      = Sets the location relative to the web root of the CSS style sheet to be used on error pages, defaults to `/shibboleth-sp/main.css`
* `conf_dir`   Sets the directory where the Shibboleth configuration is stored, defaults to `/etc/shibboleth`
* `conf_file`  Sets the name of the Shibboleth configuration file, defaults to `shibboleth2.xml`
* `sp_cert`    Sets the name of the Shibboleth Service Provider back end certificate, defaults to `sp-cert.pem`
* `bin_dir`    Sets the location of the Shibboleth tools (esp. shib-keygen), defaults to  `/usr/sbin`
* `handlerSSL`      Sets the `handlerSSL` attribute in to `true` or `false`, defaults to `true`

## Resource: `shibbloleth::attribute_map`

### Parameters for `shibbloleth::attribute_map`

* `map_uri` Sets the URI for downloading the Attribute map from. There is no default, and this parameter is required.
* `map_dir` Sets the directory into which the attribute map is downloaded, defaults to `shibbloleth::conf_dir`
* `max_age` Sets the maximum age in days for the Attribute map before downloading and replacing it, defaults to `21` days

## Class: `shibbloleth::backend_cert`

### Parameters for `shibbloleth::backend_cert`

* `sp_hostname`         Set's the hostname used to sign the back-end certifcated, defaults to `shibbloleth::hostname`

## Resource: `shibbloleth::metadata`

### Parameters for `shibbloleth::metadata`

* `provider_uri`            Sets URI for the metadata provider, there is no default and this parameter is required.
* `cert_uri`                  Sets the URI for the metadata signing certificate, there is no default and this parameter is required.
* `backing_file_dir`          Sets the directory into which the metadata is downloaded into, defaults to `shibbloleth::conf_dir`
* `backing_file_name`         Sets the name of the metadata backing file, by default this is derived from the `provider_uir`
* `cert_dir`                  Sets the directory into which the certificate is downloaded into
* `cert_file_name`            Sets the name of the certificate file, by default this is derived from the `cert_uri`
* `provider_type`             Sets the metadata provider type, defaults to 'XML'
* `provider_reload_interval`  Set's the metadata reload interval in seconds, defaults to "7200"
* `metadata_filter_max_validity_interval` Sets the maximum interval for reloading the metadata_filter, defaults to "2419200" seconds

## Resource: `shibbloleth::sso`

### Prameters for `shibbloleth::sso`
* `discoveryURL`        The URL of the discovery service, is undefined by default
* `idpURL`              The URL of a single IDp, is undefined by default
* `discoveryProtocol`   Sets the discovery protocol for the discovery service provided in the `discoveryURL`, defaults to "SAMLDS",
* `ecp_support`         Sets support for non-web based ECP logins, by default this is `false`

**Note:** Either one of `discoveryURL` or `idpURL` is required, but not both.

# Registration

Manual resgistration of the Service Provider is still required. By default, the file `/etc/shibboleth/sp-cert.pem` contains the public key of the back-end certificate used for secure comminucation within the Shibboleth Federation.

# Attribution

The `shibbloleth` Puppet module was created Aaron Hicks (hicksa@landcareresearch.co.nz) for work on the NeSI Project and the Tuakiri New Zealand Access Federation as a fork from the PuppetLabs Apache module on GitHub.

* https://github.com/puppetlabs/puppetlabs-apache
* https://github.com/nesi/puppetlabs-apache
* http://www.nesi.org.nz//
* https://tuakiri.ac.nz/confluence/display/Tuakiri/Home

# To Do

* Get rid of augeas (it's a big performance hit)

# Attribution

## puppet-blank

This module is derived from the [puppet-blank](https://github.com/Aethylred/puppet-blank) module by Aaron Hicks (aethylred@gmail.com)

This module has been developed for the use with Open Source Puppet (Apache 2.0 license) for automating server & service deployment.

* http://puppetlabs.com/puppet/puppet-open-source/
