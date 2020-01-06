RSpec.describe ActiveTransport::Delivery::Response do
  describe "attributes" do
  end

  describe "instance methods" do
    describe "#test?" do
      it "should return the boolean value of #test" do
        test_val = false
        response = ActiveTransport::Delivery::Response.new(true, {hello: "world"}, {test: test_val})
        expect(response.test?).to eq(test_val)
      end
    end

    describe "#success?" do
      it "should return the boolean value of #success" do
        success_val = false
        response = ActiveTransport::Delivery::Response.new(success_val, {hello: "world"}, {test: true})
        expect(response.success?).to eq(success_val)
      end
    end
  end
end