require_relative '../iis_object'

Puppet::Type.type(:iis_site).provide :iis_site, :parent => Puppet::Provider::IISObject do
	desc "IIS Site"

  confine :operatingsystem => :windows
  
  commands :appcmd => File.join(ENV['SystemRoot'], 'system32/inetsrv/appcmd.exe')

  mk_resource_methods

  private
  def self.iis_type
    "site"
  end

  def self.extract_complex_properties(item_xml)
    bindings = []

    item_xml.xpath("bindings/binding").each do |binding_xml|
      bindings << "#{binding_xml.attributes["protocol"].value}/#{binding_xml.attributes["bindingInformation"].value}"
    end

    { :bindings => bindings }
  end

  def get_complex_property_arg(name, value)
    case name
      when :bindings
        value ||= []
        initial_value = @initial_properties[name] || []

        unchanged_bindings = value & initial_value
        bindings_to_add = value - unchanged_bindings
        bindings_to_remove = initial_value - unchanged_bindings

        args = []

        bindings_to_add.collect do |binding|
          parts = binding.split('/', 2)
          args << "/+bindings.[protocol='#{parts[0]}',bindingInformation='#{parts[1]}']"
        end

        bindings_to_remove.collect do |binding|
          parts = binding.split('/', 2)
          args << "/-bindings.[protocol='#{parts[0]}',bindingInformation='#{parts[1]}']"
        end

        args
      else
        nil
    end
  end
end