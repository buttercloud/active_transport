require 'http'

module ActiveTransport
  module Delivery
    class GogoProvider < Provider
      class UnsupportedOperation < StandardError; end

      attr_reader :username, :password, :test, :test_url, :live_url
      attr_accessor :api_key

      def test?
        @test
      end

      def initialize(options = {}, auth = {})
        @api_key = auth[:api_key]
        @username = auth[:username]
        @password = auth[:password]
        @test = options[:test] || false
        @test_url = 'http://54.214.99.97/wp-json/gv1/'
        @live_url = 'https://letsgogo.it/wp-json/gv1/'
        set_access_token!
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

      def list_pickup_addresses
        connect("pickups/list", :get, {})
      end

      def create_pickup_address(data)
        connect("pickups/add", :post, data)
      end

      def delete_pickup_address(gogo_address_id)
        connect("pickups/remove", :post, {address_id: gogo_address_id})
      end

      def set_access_token!
        res = access_token(self.username, self.password)
        self.api_key = res.params["data"]["accessToken"]
      end

      private

      def access_token(username, password)
        api_url = self.test? ? @test_url : @live_url
        uri = URI.parse(api_url + "token")

        begin
          res = HTTP.headers(username: username, password: password)
            .post(uri.to_s)

          body = JSON.parse(res.body.to_s)

          return Response.new(body["success"], body, {test: test?})
        rescue StandardError, HTTP::Error => e
          return Response.new(false, {error: e.message}, {test: test?})
        end
      end

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
          return Response.new(false, {error: e.message}, {test: test?})
        end
      end
    end
  end
end
