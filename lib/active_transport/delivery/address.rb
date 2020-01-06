module ActiveTransport
  module Delivery
    class Address
      attr_reader :data, :line1, :line2, :city, :state, :zone, :country, :latitude, :longitude

      def initialize(data = {}, options = {})
        @data = data
        @line1 = data[:line1]
        @line2 = data[:line2]
        @city = data[:city]
        @state = data[:state]
        @zone = data[:zone]
        @country = data[:country]
        @latitude = data[:latitude]
        @longitude = data[:longitude]
      end
    end
  end
end
