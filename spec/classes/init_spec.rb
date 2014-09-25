require 'spec_helper'
describe 'shibboleth', :type => :class do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily       => 'Debian',
        :concat_basedir => '/dne',
      }
    end
    describe 'with no parameters' do
      it { should contain_class('shibboleth::params') }
    end
  end

  context 'on a RedHat OS' do
    let :facts do
      {
        :osfamily       => 'RedHat',
        :concat_basedir => '/dne',
      }
    end
    it do
      expect {
        should contain_class('shibboleth::params')
      }.to raise_error(Puppet::Error, /The shibboleth Puppet module does not support RedHat family of operating systems/)
    end
  end

    context 'on an Unknown OS' do
    let :facts do
      {
        :osfamily       => 'Unknown',
        :concat_basedir => '/dne',
      }
    end
    it do
      expect {
        should contain_class('shibboleth::params')
      }.to raise_error(Puppet::Error, /The shibboleth Puppet module does not support Unknown family of operating systems/)
    end
  end

end
