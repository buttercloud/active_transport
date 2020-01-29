RSpec.describe ActiveTransport::Delivery::GogoProvider do
  let(:api_key) { SecureRandom.hex }

  describe "attributes" do
    it "should have the proper URLs set for the API" do
      gogo = ActiveTransport::Delivery::GogoProvider.new({test: true}, {api_key: api_key})
      expect(gogo.test_url).to eq('http://54.214.99.97/wp-json/gv1/')
      expect(gogo.live_url).to eq('https://letsgogo.it/wp-json/gv1/')
    end

    it "should set the API key" do
      gogo = ActiveTransport::Delivery::GogoProvider.new({test: true}, {api_key: api_key})
      expect(gogo.api_key).to eq(api_key)
    end

    it "should set the test attribute according to what is passed" do
      gogo = ActiveTransport::Delivery::GogoProvider.new({test: true}, {api_key: api_key})
      expect(gogo.test).to be_truthy
    end
  end

  describe "instance methods" do
    describe "#test?" do
      it "should return the value of the 'test' instance attribute" do
        val = true
        gogo = ActiveTransport::Delivery::GogoProvider.new({test: val}, {api_key: api_key})

        expect(gogo.test?).to eq(val)
      end
    end

    describe "API Calls" do
      before(:each) do
        http_resp = double("HTTP::Response")
        http_body = double("HTTP::Response::Body")
        @http_client = double("HTTP::Client")
        @gogo = ActiveTransport::Delivery::GogoProvider.new({test: true}, {api_key: api_key})

        allow(HTTP).to receive(:headers).and_return(@http_client)
        allow(http_body).to receive(:to_s).and_return({success: "true", data: {hello: "back"}}.to_json)
        allow(http_resp).to receive(:body).and_return(http_body)
        allow(@http_client).to receive(:post).and_return(http_resp)
        allow(@http_client).to receive(:get).and_return(http_resp)
      end

      describe "#list_pickup_addresses" do
        it "should call the appropriate API endpoint for listing pickup addresses" do
          expect(HTTP).to receive(:headers).with(authorization: api_key)
          expect(@http_client).to receive(:get).with(URI.parse(@gogo.test_url + "pickups/list").to_s, params: {})

          @gogo.list_pickup_addresses
        end
      end

      describe "#create_pickup_address" do
        it "should call the appropriate API endpoint for creating a pickup address" do
          data = {hello: "world"}
          expect(HTTP).to receive(:headers).with(authorization: api_key)
          expect(@http_client).to receive(:post).with(URI.parse(@gogo.test_url + "pickups/add").to_s, form: data)

          @gogo.create_pickup_address(data)
        end
      end

      describe "#delete_pickup_address" do
        it "should call the appropriate API endpoint for deleting a pickup address" do
          address_id = 3
          data = {address_id: address_id}
          expect(HTTP).to receive(:headers).with(authorization: api_key)
          expect(@http_client).to receive(:post).with(URI.parse(@gogo.test_url + "pickups/remove").to_s, form: data)

          @gogo.delete_pickup_address(address_id)
        end
      end

      describe "#store_address" do
        it "should call the appropriate API endpoint for deleting an order" do
          data = {hello: "world"}
          expect(HTTP).to receive(:headers).with(authorization: api_key)
          expect(@http_client).to receive(:post).with(URI.parse(@gogo.test_url + "address").to_s, form: data)

          @gogo.store_address(data)
        end
      end

      describe "#delete_order" do
        it "should call the appropriate API endpoint for deleting an order" do
          order_id = "1"
          expect(HTTP).to receive(:headers).with(authorization: api_key)
          expect(@http_client).to receive(:post).with(URI.parse(@gogo.test_url + "orders/void").to_s, form: {order_id: order_id})

          @gogo.delete_order(order_id)
        end
      end

      describe "#get_cost" do
        it "should call the appropriate API endpoint for getting the cost of an order" do
          address = ActiveTransport::Delivery::Address.new(latitude: "12", longitude: "13")

          expect(HTTP).to receive(:headers).with(authorization: api_key)
          expect(@http_client).to receive(:get).with(URI.parse(@gogo.test_url + "prices").to_s, params: {longitude: address.longitude, latitude: address.latitude})

          @gogo.get_cost(address)
        end
      end

      describe "#track_order" do
        it "should call the appropriate API endpoint for tracking an order" do
          order_id = "1"
          data = {order_id: order_id}
          expect(HTTP).to receive(:headers).with(authorization: api_key)
          expect(@http_client).to receive(:get).with(URI.parse(@gogo.test_url + "tracking").to_s, params: data)

          @gogo.track_order(order_id)
        end
      end

      describe "#update_order" do
        it "should raise an unsupported method exception" do
          expect { @gogo.update_order({}) }.to raise_exception(ActiveTransport::Delivery::GogoProvider::UnsupportedOperation)
        end
      end

      describe "#create_order" do
        it "should call the appropriate API endpoint for creating an order" do
          data = {hello: "world"}
          expect(HTTP).to receive(:headers).with(authorization: api_key)
          expect(@http_client).to receive(:post).with(URI.parse(@gogo.test_url + "orders").to_s, form: data)

          @gogo.create_order(data)
        end
      end
    end
  end
end