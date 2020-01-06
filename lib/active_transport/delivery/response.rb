module ActiveTransport
  module Delivery
    class Response
      attr_reader :params, :test, :success

      def initialize(success, params = {}, options = {})
        @success, @params = success, params
        @test = options[:test] || false
      end

      def success?
        @success      
      end

      def test?
        @test
      end
    end
  end
end
