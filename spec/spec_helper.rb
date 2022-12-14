require "bundler/setup"
require "vinfly"
require 'webmock/rspec'
require 'webmock_responses'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    api_response = WebmockResponses.api_response
    api_response_brief = WebmockResponses.api_response_brief
    api_response_wrong_vin = WebmockResponses.api_response_wrong_vin
    api_response_http_error_code = WebmockResponses.api_response_http_error_code

    api_url = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevin"

    #note the different VIN numbers used by the following stub requests
    stub_request(:get, "#{api_url}/3AKJHHDR3KSKX6689?format=json").to_return(status: 200, body: api_response.to_json, headers: {"Content-Type" => 'application/json'})
    stub_request(:get, "#{api_url}/3AKJHHDR1KSKX6688?format=json").to_return(status: 200, body: api_response_brief.to_json, headers: {"Content-Type" => 'application/json'})
    stub_request(:get, "#{api_url}/1AKJHHDR3KSKX6689?format=json").to_return(status: 200, body: api_response_wrong_vin.to_json, headers: {"Content-Type" => 'application/json'})
    
    #using the following stub request to test an API error cases by returning a non-200 status code and an error message in the response body.
    stub_request(:get, "#{api_url}/ReturnHTTPError?format=json").to_return(status: 404, body: api_response_http_error_code.to_json, headers: {"Content-Type" => 'application/json'})
    stub_request(:get, "#{api_url}/Timeout?format=json").to_timeout
  end

end
