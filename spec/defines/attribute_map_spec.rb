require 'spec_helper'

describe 'shibboleth::attribute_map', :type => :define do
  let :pre_condition do
    "include apache\ninclude apache::mod::shib\ninclude shibboleth"
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
      }
    end
    let(:title){ 'map_name' }
    describe 'with minimum parameters' do
      let(:params){ { :map_uri => 'http://example.org/attribute_map.xml' } }
      it { should contain_exec("get_map_name_attribute_map").with(
        'path'    => ['/usr/bin'],
        'command' => 'wget http://example.org/attribute_map.xml -O /etc/shibboleth/map_name.xml',
        'unless'  => 'test `find /etc/shibboleth/map_name.xml -mtime +21`',
        'notify'  => ['Service[httpd]','Service[shibd]']
      ) }
      it { should contain_augeas("shib_map_name_attribute_map").with(
        'lens'    => 'Xml.lns',
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => [
          'set AttributeExtractor/#attribute/path map_name.xml',
        ],
        'notify'  => ['Service[httpd]','Service[shibd]'],
        'require' => 'Exec[get_map_name_attribute_map]'
      ) }
    end
    describe 'with all parameters' do
      let(:params){ {
        :map_uri  => 'http://bob.org/bobs_attribute_map.xml',
        :map_dir  => '/some/path/to',
        :max_age            => '5'
      } }
      it { should contain_exec("get_map_name_attribute_map").with(
        'command' => 'wget http://bob.org/bobs_attribute_map.xml -O /some/path/to/map_name.xml',
        'unless'  => 'test `find /some/path/to/map_name.xml -mtime +5`'
      ) }
      it { should contain_augeas("shib_map_name_attribute_map").with(
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => [
          'set AttributeExtractor/#attribute/path map_name.xml',
        ]
      ) }
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
      }
    end
    let(:title){ 'map_name' }
    describe 'with minimum parameters' do
      let(:params){ { :map_uri => 'http://example.org/attribute_map.xml' } }
      it { should contain_exec("get_map_name_attribute_map").with(
        'path'    => ['/usr/bin'],
        'command' => 'wget http://example.org/attribute_map.xml -O /etc/shibboleth/map_name.xml',
        'unless'  => 'test `find /etc/shibboleth/map_name.xml -mtime +21`',
        'notify'  => ['Service[httpd]','Service[shibd]']
      ) }
      it { should contain_augeas("shib_map_name_attribute_map").with(
        'lens'    => 'Xml.lns',
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => [
          'set AttributeExtractor/#attribute/path map_name.xml',
        ],
        'notify'  => ['Service[httpd]','Service[shibd]'],
        'require' => 'Exec[get_map_name_attribute_map]'
      ) }
    end
    describe 'with all parameters' do
      let(:params){ {
        :map_uri  => 'http://bob.org/bobs_attribute_map.xml',
        :map_dir  => '/some/path/to',
        :max_age            => '5'
      } }
      it { should contain_exec("get_map_name_attribute_map").with(
        'command' => 'wget http://bob.org/bobs_attribute_map.xml -O /some/path/to/map_name.xml',
        'unless'  => 'test `find /some/path/to/map_name.xml -mtime +5`'
      ) }
      it { should contain_augeas("shib_map_name_attribute_map").with(
        'incl'    => '/etc/shibboleth/shibboleth2.xml',
        'context' => '/files/etc/shibboleth/shibboleth2.xml/SPConfig/ApplicationDefaults',
        'changes' => [
          'set AttributeExtractor/#attribute/path map_name.xml',
        ]
      ) }
    end
  end
end