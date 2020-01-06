module ActiveTransport
  module Delivery
    def self.camelize(term)
      first, second = term.split("_")
      first[0] = first[0].upcase
      second[0] = second[0].upcase

      "#{first}#{second}"
    end

    load_path = Pathname.new(__FILE__ + '/../../..')
    Dir[File.dirname(__FILE__) + '/providers/**/*.rb'].each do |filename|
      gateway_name      = File.basename(filename, '.rb')
      gateway_classname = self.camelize("#{gateway_name}_provider")
      gateway_filename  = Pathname.new(filename).relative_path_from(load_path).sub_ext('')

      autoload(gateway_classname, gateway_filename)
    end
  end
end
