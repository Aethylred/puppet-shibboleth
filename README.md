# Shibboleth

The Shibboleth Puppet module is intended as a companion module to the [PuppetLabs Apache module](https://forge.puppetlabs.com/puppetlabs/apache) that manages the Shibboleth services used by Service Providers (SP) and Identity Providers (IDp).

These shibboleth services are tightly bound to the installation of the Shibboleth Apache module `mod_shib` so the resources provided in this module are dependent on the use of the `apache::mod::shib` class from the PuppetLabs Apache module.

# To Do

* Get rid of augeas (it's a big performance hit)

# Attribution

## puppet-blank

This module is derived from the [puppet-blank](https://github.com/Aethylred/puppet-blank) module by Aaron Hicks (aethylred@gmail.com)

This module has been developed for the use with Open Source Puppet (Apache 2.0 license) for automating server & service deployment.

* http://puppetlabs.com/puppet/puppet-open-source/
