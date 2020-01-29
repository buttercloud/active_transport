require 'pry'

RSpec.describe ActiveTransport::Delivery::TookanProvider do
  let(:api_key) { SecureRandom.hex }

  describe "attributes" do
    it "should have the proper URLs set for the API" do
      tookan = ActiveTransport::Delivery::TookanProvider.new({test: true}, {api_key: api_key})
      expect(tookan.test_url).to eq('https://api.tookanapp.com/v2/')
      expect(tookan.live_url).to eq('https://api.tookanapp.com/v2/')
    end

    it "should set the API key" do
      tookan = ActiveTransport::Delivery::TookanProvider.new({test: true}, {api_key: api_key})
      expect(tookan.api_key).to eq(api_key)
    end

    it "should set the test attribute according to what is passed" do
      tookan = ActiveTransport::Delivery::TookanProvider.new({test: true}, {api_key: api_key})
      expect(tookan.test).to be_truthy
    end
  end

  describe "instance methods" do
    describe "#test?" do
      it "should return the value of the 'test' instance attribute" do
        val = true
        tookan = ActiveTransport::Delivery::TookanProvider.new({test: val}, {api_key: api_key})

        expect(tookan.test?).to eq(val)
      end
    end

    describe "API Calls" do
      before(:each) do
        http_resp = double("HTTP::Response")
        http_body = double("HTTP::Response::Body")
        @tookan = ActiveTransport::Delivery::TookanProvider.new({test: true}, {api_key: api_key})

        allow(http_body).to receive(:to_s).and_return({success: "true", data: {hello: "back"}}.to_json)
        allow(http_resp).to receive(:body).and_return(http_body)
        allow(HTTP).to receive(:post).and_return(http_resp)
        allow(HTTP).to receive(:get).and_return(http_resp)
      end

      describe "#list_pickup_addresses" do
        it "should raise an unsupported method exception" do
          expect { @tookan.list_pickup_addresses }.to raise_exception(ActiveTransport::Delivery::TookanProvider::UnsupportedOperation)
        end
      end

      describe "#create_pickup_address" do
        it "should raise an unsupported method exception" do
          expect { @tookan.create_pickup_address({}) }.to raise_exception(ActiveTransport::Delivery::TookanProvider::UnsupportedOperation)
        end
      end

      describe "#delete_pickup_address" do
        it "should raise an unsupported method exception" do
          expect { @tookan.delete_pickup_address(3) }.to raise_exception(ActiveTransport::Delivery::TookanProvider::UnsupportedOperation)
        end
      end

      describe "#store_address" do
        it "should call the appropriate API endpoint for deleting an order" do
          data = {hello: "world", api_key: api_key}
          expect(HTTP).to receive(:post).with(URI.parse(@tookan.test_url + "customer/edit").to_s, json: data)

          @tookan.store_address(data)
        end
      end

      describe "#delete_order" do
        it "should call the appropriate API endpoint for deleting an order" do
          order_id = "1"
          expect(HTTP).to receive(:post).with(URI.parse(@tookan.test_url + "delete_task").to_s, json: {job_id: order_id, api_key: api_key})

          @tookan.delete_order(order_id)
        end
      end

      describe "#get_cost" do
        it "should raise an unsupported method exception" do
          address = ActiveTransport::Delivery::Address.new(latitude: "12", longitude: "13")

          expect { @tookan.get_cost(address) }.to raise_exception(ActiveTransport::Delivery::TookanProvider::UnsupportedOperation)
        end
      end

      describe "#track_order" do
        it "should call the appropriate API endpoint for tracking an order" do
          order_ids = ["1", "2"]
          data = {job_ids: order_ids, include_task_history: 0, api_key: api_key}
          expect(HTTP).to receive(:post).with(URI.parse(@tookan.test_url + "get_job_details").to_s, json: data)

          @tookan.track_order(order_ids)
        end
      end

      describe "#create_driver" do
        it "should call the appropriate API endpoint for creating a driver account" do
          data = {hello: "world", api_key: api_key}
          expect(HTTP).to receive(:post).with(URI.parse(@tookan.test_url + "add_agent").to_s, json: data)

          @tookan.create_driver(data)
        end
      end

      describe "#delete_driver_account" do
        it "should call the appropriate API endpoint for deleting a driver account" do
          driver_id = 1
          data = {fleet_id: driver_id, api_key: api_key}
          expect(HTTP).to receive(:post).with(URI.parse(@tookan.test_url + "delete_fleet_account").to_s, json: data)

          @tookan.delete_driver_account(driver_id)
        end
      end

      describe "#get_driver_location" do
        it "should call the appropriate API endpoint for getting a driver location" do
          driver_id = 1
          data = {fleet_id: driver_id, api_key: api_key}
          expect(HTTP).to receive(:post).with(URI.parse(@tookan.test_url + "get_fleet_location").to_s, json: data)

          @tookan.get_driver_location(driver_id)
        end
      end

      describe "#get_teams" do
        it "should call the appropriate API endpoint for getting teams" do
          data = {api_key: api_key}
          expect(HTTP).to receive(:post).with(URI.parse(@tookan.test_url + "view_all_team_only").to_s, json: data)

          @tookan.get_teams
        end
      end

      describe "#update_order" do
        it "should call the appropriate API endpoint for updating an order" do
          data = {hello: "world", api_key: api_key}
          expect(HTTP).to receive(:post).with(URI.parse(@tookan.test_url + "edit_task").to_s, json: data)

          @tookan.update_order(data)
        end
      end

      describe "#create_order" do
        it "should call the appropriate API endpoint for creating an order" do
          data = {hello: "world", api_key: api_key}
          expect(HTTP).to receive(:post).with(URI.parse(@tookan.test_url + "create_multiple_tasks").to_s, json: data)

          @tookan.create_order(data)
        end
      end
    end
  end
end