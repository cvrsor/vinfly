require 'spec_helper'

RSpec.describe ApiHelper do
    let(:api_response) { call_vpic_api('3AKJHHDR3KSKX6689') }
    it "returns correctly vPIC API's response" do
      expect(api_response).to be_kind_of(Hash)
      expect(api_response).to have_key("Results")
      expect(api_response).to have_key("Count")
    end

    it 'outputs the response\'s error message, when the API request was not successful (non-2xx status code)' do
        expected_output = "An error occurred while requesting information from the vPIC API: 404 - : No HTTP resource was found that matches the request URI 'https://backend-vpic-api.nhtsa.gov/api/vehicles/wrong-api-endpoint/1AKJHHDR3KSKX6689?format=json\n"
        expect do
            Vinfly::CLI.new.invoke(:decode_vin, ['ReturnHTTPError'], {})
        end.to output(expected_output).to_stdout
    end

    it 'outputs an error message when the API request times out' do
      expected_output = "The request timed out or the connection was refused\n"
      expect do
          Vinfly::CLI.new.invoke(:decode_vin, ['Timeout'], {})
      end.to output(expected_output).to_stdout
  end

end