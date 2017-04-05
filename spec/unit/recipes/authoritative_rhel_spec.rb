require 'spec_helper'

describe 'pdns_test::authoritative_install_single_bind' do
  context 'on rhel platform' do
    let(:rhel_runner) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.8',
        step_into: ['pdns_authoritative_install', 'pdns_authoritative_config', 'pdns_authoritative_service']) do |node|
        node.automatic['packages']['centos-release']['version'] = '6'
      end
    end

    let(:chef_run) { rhel_runner.converge(described_recipe) }
    let(:version) { '4.0.3-1pdns.el6' }

    #
    # Tests for the install resource
    #

    it'installs epel-release package' do
      expect(chef_run).to install_yum_package('epel-release')
    end

    it'adds yum repository powerdns-auth-40' do
      expect(chef_run).to create_yum_repository('powerdns-auth-40')
    end

    it'adds yum repository powerdns-auth-40-debuginfo' do
      expect(chef_run).to create_yum_repository('powerdns-auth-40-debuginfo')
    end

    it'installs pdns authoritative package' do
      expect(chef_run).to install_yum_package('pdns').with(version: version)
    end

    #
    # Tests for the service resource
    #

    it 'creates a specific init script' do
      expect(chef_run).to create_template('/etc/init.d/pdns-authoritative-server-01')
    end

    it 'enables and starts pdns_authoritative service' do
      expect(chef_run).to enable_service('pdns-authoritative-server-01').with(pattern: 'pdns_server')
      expect(chef_run).to start_service('pdns-authoritative-server-01').with(pattern: 'pdns_server')
    end

    #
    # Tests for the config resource
    #

    it 'creates pdns config directory' do
      expect(chef_run).to create_directory('/etc/pdns')
      .with(owner: 'root', group: 'root', mode: '0755')
    end

    it 'creates pdns authoritative unix user' do
      expect(chef_run).to create_user('pdns')
      .with(home: '/', shell: '/sbin/nologin', system: true)
    end

    it 'creates a pdns authoritative unix group' do
      expect(chef_run).to create_group('pdns')
      .with(members: ['pdns'], system: true)
    end

    xit 'creates a pdns authoritative socket directory' do
      expect(chef_run).to create_directory('/var/run/pdns-authoritative-server-01')
    end

    it 'creates a authoritative instance config' do
      expect(chef_run).to create_template('/etc/pdns/pdns-authoritative-server-01.conf')
      .with(owner: 'root', group: 'root', mode: '0640')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end