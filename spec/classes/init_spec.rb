require 'spec_helper'

describe 'shibboleth', :type => :class do
  let :pre_condition do
    "include apache\ninclude apache::mod::shib"
  end
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'squeeze',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :fqdn                   => 'test.example.com',
      }
    end
    describe 'with no parameters' do
      it { should contain_user('_shibd').with(
        'ensure'  => 'present',
        'home'    => '/var/log/shibboleth',
        'shell'   => '/bin/false',
        'require' => 'Class[Apache::Mod::Shib]'
      ) }
      it { should contain_file('shibboleth_conf_dir').with(
        'ensure'  => 'directory',
        'path'    => '/etc/shibboleth',
        'owner'   => '_shibd',
        'group'   => '_shibd',
        'require' => 'Class[Apache::Mod::Shib]'
      ) }
      it { should contain_file('shibboleth_config_file').with(
        'ensure'  => 'file',
        'path'    => '/etc/shibboleth/shibboleth2.xml',
        'replace' => false,
        'require' => ['Class[Apache::Mod::Shib]','File[shibboleth_conf_dir]']
      ) }
      it { should contain_augeas('sp_config_resources').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => [
          'set Errors/#attribute/supportContact root@localhost',
          'set Errors/#attribute/logoLocation /shibboleth-sp/logo.jpg',
          'set Errors/#attribute/styleSheet /shibboleth-sp/main.css',
        ],
        'notify'  => ['Service[httpd]','Service[shibd]']
      ) }
      it { should contain_augeas('sp_config_consistent_address').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => [
          'set Sessions/#attribute/consistentAddress true',
        ],
        'notify'  => ['Service[httpd]','Service[shibd]']
      ) }
      it { should contain_augeas('sp_config_hostname').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => [
          'set #attribute/entityID https://test.example.com/shibboleth',
          'set Sessions/#attribute/handlerURL https://test.example.com/Shibboleth.sso',
        ],
        'notify'  => ['Service[httpd]','Service[shibd]']
      ) }
      it { should contain_augeas('sp_config_handlerSSL').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => ['set Sessions/#attribute/handlerSSL true',],
        'notify'  => ['Service[httpd]','Service[shibd]']
      ) }
      it { should contain_service('shibd').with(
        'ensure'      => 'running',
        'enable'      => true,
        'hasrestart'  => true,
        'hasstatus'   => true,
        'require'     => '[Class[Apache::Mod::Shib],User[_shibd]'
      ) }
      # The module isn't set up for testing the changes augeas makes.
    end
  end
  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :fqdn                   => 'test.example.com',
      }
    end
    describe 'with no parameters' do
      it { should contain_file('shibboleth_conf_dir').with(
        'ensure'  => 'directory',
        'path'    => '/etc/shibboleth',
        'require' => 'Class[Apache::Mod::Shib]'
      ) }
      it { should contain_file('shibboleth_config_file').with(
        'ensure'  => 'file',
        'path'    => '/etc/shibboleth/shibboleth2.xml',
        'replace' => false,
        'require' => ['Class[Apache::Mod::Shib]','File[shibboleth_conf_dir]']
      ) }
      it { should contain_augeas('sp_config_resources').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => [
          'set Errors/#attribute/supportContact root@localhost',
          'set Errors/#attribute/logoLocation /shibboleth-sp/logo.jpg',
          'set Errors/#attribute/styleSheet /shibboleth-sp/main.css',
        ],
        'notify'  => ['Service[httpd]','Service[shibd]']
      ) }
      it { should contain_augeas('sp_config_consistent_address').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => [
          'set Sessions/#attribute/consistentAddress true',
        ],
        'notify'  => ['Service[httpd]','Service[shibd]']
      ) }
      it { should contain_augeas('sp_config_hostname').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => [
          'set #attribute/entityID https://test.example.com/shibboleth',
          'set Sessions/#attribute/handlerURL https://test.example.com/Shibboleth.sso',
        ],
        'notify'  => ['Service[httpd]','Service[shibd]']
      ) }
      it { should contain_augeas('sp_config_handlerSSL').with(
        'lens'    => 'Xml.lns',
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => ['set Sessions/#attribute/handlerSSL true',],
        'notify'  => ['Service[httpd]','Service[shibd]']
      ) }
      it { should contain_service('shibd').with(
        'ensure'      => 'running',
        'enable'      => true,
        'hasrestart'  => true,
        'hasstatus'   => true,
        'require'     => 'Class[Apache::Mod::Shib]'
      ) }
      # The module isn't set up for testing the changes augeas makes.
    end
  end
end
