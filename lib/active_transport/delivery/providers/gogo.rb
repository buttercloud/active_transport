require 'http'

module ActiveTransport
  module Delivery
    class GogoProvider < Provider
      class UnsupportedOperation < StandardError; end

      attr_reader :api_key, :test, :test_url, :live_url

      def test?
        @test
      end

      def initialize(options = {}, auth = {})
        @api_key = auth[:api_key]
        @test = options[:test] || false
        @test_url = 'http://54.214.99.97/wp-json/gv1/'
        @live_url = 'https://letsgogo.it/wp-json/gv1/'
      end

      def create_order(data)
        connect("orders", :post, data)
      end

      def update_order(data)
        raise UnsupportedOperation.new("Operation not supported on Gogo Delivery")
      end

      def get_teams
        raise UnsupportedOperation.new("Operation not supported on Gogo Delivery")
      end

      def get_driver_location(driver_id)
        raise UnsupportedOperation.new("Operation not supported on Gogo Delivery")
      end

      def delete_driver_account(driver_id)
        raise UnsupportedOperation.new("Operation not supported on Gogo Delivery")
      end

      def create_driver(data)
        raise UnsupportedOperation.new("Operation not supported on Gogo Delivery")
      end

      def track_order(order_id)
        connect("tracking", :get, {order_id: order_id})
      end

      def get_cost(address)
        connect("prices", :get, {longitude: address.longitude, latitude: address.latitude})
      end

      def delete_order(order_id)
        connect("orders/void", :post, {order_id: order_id})
      end

      def store_address(data)
        connect("address", :post, data)
      end

      private

      def connect(path, http_method, data)
        api_url = self.test? ? @test_url : @live_url
        uri = URI.parse(api_url + path)

        begin
          res = if http_method == :post
            HTTP.headers(authorization: api_key)
              .post(uri.to_s, form: data)
          elsif http_method == :get
            HTTP.headers(authorization: api_key)
              .get(uri.to_s, params: data)
          end

          body = JSON.parse(res.body.to_s)

          return Response.new(body["success"], body, {test: test?})
        rescue StandardError, HTTP::Error => e
          return Response.new(false, e.message, {test: test?})
        end
      end
    end
  end
end
