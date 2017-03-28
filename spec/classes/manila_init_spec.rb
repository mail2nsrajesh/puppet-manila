require 'spec_helper'
describe 'manila' do
  let :req_params do
    {
      :rabbit_password => 'guest',
      :sql_connection  => 'mysql+pymysql://user:password@host/database',
      :purge_config    => false,
    }
  end

  let :facts do
    @default_facts.merge({:osfamily => 'Debian'})
  end

  describe 'with only required params' do
    let :params do
      req_params
    end

    it { is_expected.to contain_class('manila::logging') }
    it { is_expected.to contain_class('manila::params') }

    it 'passes purge to resource' do
      is_expected.to contain_resources('manila_config').with({
        :purge => false
      })
    end

    it 'should contain default config' do
      is_expected.to contain_manila_config('DEFAULT/rpc_backend').with(
        :value => 'rabbit'
      )
      is_expected.to contain_manila_config('DEFAULT/transport_url').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('DEFAULT/rpc_response_timeout').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('oslo_messaging_notifications/transport_url').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('oslo_messaging_notifications/topics').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('oslo_messaging_notifications/driver').with(
        :value => 'messaging'
      )
      is_expected.to contain_manila_config('DEFAULT/control_exchange').with(
        :value => 'openstack'
      )
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_password').with(
        :value => 'guest',
        :secret => true
      )
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_host').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('oslo_messaging_rabbit/amqp_durable_queues').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_port').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_hosts').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_ha_queues').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_virtual_host').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_userid').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('DEFAULT/debug').with(
        :value => '<SERVICE DEFAULT>'
      )
      is_expected.to contain_manila_config('DEFAULT/storage_availability_zone').with(
        :value => 'nova'
      )
      is_expected.to contain_manila_config('DEFAULT/api_paste_config').with(
        :value => '/etc/manila/api-paste.ini'
      )
      is_expected.to contain_manila_config('DEFAULT/rootwrap_config').with(
        :value => '/etc/manila/rootwrap.conf'
      )
      is_expected.to contain_manila_config('DEFAULT/state_path').with(
        :value => '/var/lib/manila'
      )
      is_expected.to contain_manila_config('oslo_concurrency/lock_path').with(
        :value => '/tmp/manila/manila_locks'
      )
      is_expected.to contain_oslo__messaging__rabbit('manila_config').with(
        :rabbit_use_ssl     => '<SERVICE DEFAULT>',
      )
      is_expected.to contain_oslo__log('manila_config').with(:log_dir => '/var/log/manila')
    end
  end

  describe 'with modified rabbit_hosts' do
    let :params do
      req_params.merge({'rabbit_hosts' => ['rabbit1:5672', 'rabbit2:5672']})
    end

    it 'should contain many' do
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_host').with(
        :value => '<SERVICE DEFAULT>')
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_port').with(
        :value => '<SERVICE DEFAULT>')
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_hosts').with(
        :value => 'rabbit1:5672,rabbit2:5672'
      )
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_ha_queues').with(
        :value => true
      )
    end
  end

  describe 'with a single rabbit_hosts entry' do
    let :params do
      req_params.merge({'rabbit_hosts' => ['rabbit1:5672']})
    end

    it 'should contain many' do
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_host').with(
        :value => '<SERVICE DEFAULT>')
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_port').with(
        :value => '<SERVICE DEFAULT>')
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_hosts').with(
        :value => 'rabbit1:5672'
      )
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_ha_queues').with(
        :value => '<SERVICE DEFAULT>'
      )
    end
  end

  describe 'a single rabbit_host with enable ha queues' do
    let :params do
      req_params.merge({'rabbit_ha_queues' => true})
    end

    it 'should contain rabbit_ha_queues' do
      is_expected.to contain_manila_config('oslo_messaging_rabbit/rabbit_ha_queues').with(
        :value => true
      )
    end
  end

  describe 'with SSL enabled' do
    let :params do
      req_params.merge!({
        :rabbit_use_ssl     => true,
        :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
        :kombu_ssl_certfile => '/path/to/ssl/cert/file',
        :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
        :kombu_ssl_version  => 'TLSv1'
      })
    end

    it { is_expected.to contain_oslo__messaging__rabbit('manila_config').with(
      :rabbit_use_ssl     => true,
      :kombu_ssl_ca_certs => '/path/to/ssl/ca/certs',
      :kombu_ssl_certfile => '/path/to/ssl/cert/file',
      :kombu_ssl_keyfile  => '/path/to/ssl/keyfile',
      :kombu_ssl_version  => 'TLSv1'
    )}
  end

  describe 'with SSL enabled without kombu' do
    let :params do
      req_params.merge!({
        :rabbit_use_ssl     => true,
      })
    end

    it { is_expected.to contain_oslo__messaging__rabbit('manila_config').with(
      :rabbit_use_ssl     => true,
    )}
  end

  describe 'with SSL disabled' do
    let :params do
      req_params.merge!({
        :rabbit_use_ssl     => false,
      })
    end

    it { is_expected.to contain_oslo__messaging__rabbit('manila_config').with(
      :rabbit_use_ssl     => false,
    )}
  end

  describe 'with amqp_durable_queues disabled' do
    let :params do
      req_params.merge({
        :amqp_durable_queues => false,
      })
    end

    it { is_expected.to contain_manila_config('oslo_messaging_rabbit/amqp_durable_queues').with_value(false) }
  end

  describe 'with amqp_durable_queues enabled' do
    let :params do
      req_params.merge({
        :amqp_durable_queues => true,
      })
    end

    it { is_expected.to contain_manila_config('oslo_messaging_rabbit/amqp_durable_queues').with_value(true) }
  end

  describe 'with sqlite' do
    let :params do
      {
        :sql_connection        => 'sqlite:////var/lib/manila/manila.sqlite',
        :rabbit_password       => 'guest',
      }
    end

    it { is_expected.to_not contain_class('mysql::python') }
    it { is_expected.to_not contain_class('mysql::bindings') }
    it { is_expected.to_not contain_class('mysql::bindings::python') }
  end

  describe 'with SSL socket options set' do
    let :params do
      {
        :use_ssl         => true,
        :cert_file       => '/path/to/cert',
        :ca_file         => '/path/to/ca',
        :key_file        => '/path/to/key',
        :rabbit_password => 'guest',
      }
    end

    it { is_expected.to contain_manila_config('DEFAULT/ssl_ca_file').with_value('/path/to/ca') }
    it { is_expected.to contain_manila_config('DEFAULT/ssl_cert_file').with_value('/path/to/cert') }
    it { is_expected.to contain_manila_config('DEFAULT/ssl_key_file').with_value('/path/to/key') }
  end

  describe 'with SSL socket options set to false' do
    let :params do
      {
        :use_ssl         => false,
        :cert_file       => false,
        :ca_file         => false,
        :key_file        => false,
        :rabbit_password => 'guest',
      }
    end

    it { is_expected.to contain_manila_config('DEFAULT/ssl_ca_file').with_ensure('absent') }
    it { is_expected.to contain_manila_config('DEFAULT/ssl_cert_file').with_ensure('absent') }
    it { is_expected.to contain_manila_config('DEFAULT/ssl_key_file').with_ensure('absent') }
  end

  describe 'with SSL socket options set wrongly configured' do
    let :params do
      {
        :use_ssl         => true,
        :ca_file         => '/path/to/ca',
        :key_file        => '/path/to/key',
        :rabbit_password => 'guest',
      }
    end

    it_raises 'a Puppet::Error', /The cert_file parameter is required when use_ssl is set to true/
  end

  describe 'with transport_url entries' do

    let :params do
      {
        :default_transport_url      => 'rabbit://rabbit_user:password@localhost:5673',
        :rpc_response_timeout       => '120',
        :control_exchange           => 'manila',
        :notification_transport_url => 'rabbit://rabbit_user:password@localhost:5673',
      }
    end

    it { is_expected.to contain_manila_config('DEFAULT/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673') }
    it { is_expected.to contain_manila_config('DEFAULT/rpc_response_timeout').with_value('120') }
    it { is_expected.to contain_manila_config('DEFAULT/control_exchange').with_value('manila') }
    it { is_expected.to contain_manila_config('oslo_messaging_notifications/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673') }
  end

  describe 'with amqp rpc supplied' do

    let :params do
      {
        :sql_connection         => 'mysql+pymysql://user:password@host/database',
        :rpc_backend            => 'amqp',
      }
    end

    it { is_expected.to contain_manila_config('oslo_messaging_amqp/server_request_prefix').with_value('exclusive') }
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/broadcast_prefix').with_value('broadcast') }
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/group_request_prefix').with_value('unicast') }
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/container_name').with_value('guest') }
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/idle_timeout').with_value('0') }
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/trace').with_value(false) }
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/allow_insecure_clients').with_value(false) }
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/ssl_key_password').with_value('<SERVICE DEFAULT>')}
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/ssl_ca_file').with_value('<SERVICE DEFAULT>')}
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/ssl_cert_file').with_value('<SERVICE DEFAULT>')}
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/ssl_key_file').with_value('<SERVICE DEFAULT>')}
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>')}
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>')}
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>')}
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/username').with_value('<SERVICE DEFAULT>')}
    it { is_expected.to contain_manila_config('oslo_messaging_amqp/password').with_value('<SERVICE DEFAULT>')}
  end

end
