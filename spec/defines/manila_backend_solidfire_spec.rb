require 'spec_helper'

describe 'manila::backend::solidfire' do
  let (:title) { 'solidfire' }

  let :req_params do
    {
      :san_ip       => '127.0.0.2',
      :san_login    => 'solidfire',
      :san_password => 'password',
    }
  end

  let :params do
    req_params
  end

  describe 'solidfire volume driver' do
    it 'configure solidfire volume driver' do
      should contain_manila_config('solidfire/volume_driver').with_value(
        'manila.volume.drivers.solidfire.SolidFire')
      should contain_manila_config('solidfire/san_ip').with_value(
        '127.0.0.2')
      should contain_manila_config('solidfire/san_login').with_value(
        'solidfire')
      should contain_manila_config('solidfire/san_password').with_value(
        'password')
    end
  end
end
