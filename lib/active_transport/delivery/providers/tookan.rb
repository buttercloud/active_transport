require 'http'

module ActiveTransport
  module Delivery
    class TookanProvider < Provider
      class UnsupportedOperation < StandardError; end

      attr_reader :api_key, :test, :test_url, :live_url

      def test?
        @test
      end

      def initialize(options = {}, auth = {})
        @api_key = auth[:api_key]
        @test = options[:test] || false
        @test_url = 'https://api.tookanapp.com/v2/'
        @live_url = 'https://api.tookanapp.com/v2/'
      end

      def create_order(data)
        connect("create_multiple_tasks", :post, data)
      end

      def update_order(data)
        connect("edit_task", :post, data)
      end

      def get_teams
        connect("view_all_team_only", :post, {})
      end

      def create_driver(data)
        connect("add_agent", :post, data)
      end

      def get_driver_location(driver_id)
        connect("get_fleet_location", :post, {fleet_id: driver_id})
      end

      def delete_driver_account(driver_id)
        connect("delete_fleet_account", :post, {fleet_id: driver_id})
      end

      def track_order(order_ids=[])
        connect("get_job_details", :post, {job_ids: order_ids, include_task_history: 0})
      end

      def get_cost(address)
        raise UnsupportedOperation.new("Operation not supported on Tookan")
      end

      def delete_order(order_id)
        connect("delete_task", :post, {job_id: order_id})
      end

      def store_address(data)
        connect("customer/edit", :post, data)
      end

      private

      def connect(path, http_method, data)
        api_url = self.test? ? @test_url : @live_url
        uri = URI.parse(api_url + path)
        data.merge!({api_key: @api_key})

        begin
          res = if http_method == :post
            HTTP.post(uri.to_s, json: data)
          elsif http_method == :get
            HTTP.get(uri.to_s, params: data)
          end

          body = JSON.parse(res.body.to_s)

          return Response.new(body["status"] == 200, body, {test: test?})
        rescue StandardError, HTTP::Error => e
          return Response.new(false, e.message, {test: test?})
        end
      end
    end
  end
end
