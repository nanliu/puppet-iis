require_relative '../iis_object'

Puppet::Type.type(:iis_apppool).provide :iis_apppool, :parent => Puppet::Provider::IISObject do
	desc "IIS App Pool"

  confine :operatingsystem => :windows

  commands :appcmd => File.join(ENV['SystemRoot'], 'system32/inetsrv/appcmd.exe')

  mk_resource_methods

  private
  def self.iis_type
    "apppool"
  end
end