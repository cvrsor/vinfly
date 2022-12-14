#!/usr/bin/env ruby

# Sample client that connects to the gRPC Decodevin service
#
# Usage: $ path/to/test_client.rb

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, '../lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'vin_services_pb'
require 'google/protobuf/well_known_types'


def main
  vinnumber = ARGV.size > 0 ?  ARGV[0] : '3AKJHHDR3KSKX6689'  
  port = 5001
  hostname = ARGV.size > 1 ?  ARGV[1] : "localhost:#{port.to_s}"
  puts "Client, requesting VIN number #{vinnumber} from host: #{hostname}"
  stub = Decodevin::Vin::Stub.new(hostname, :this_channel_is_insecure)
  begin
    api_response = stub.decode_vin(Decodevin::VinRequest.new(vinnumber: vinnumber)).results
    results = api_response['Results']
    puts "Received #{results.length} fields from gRPC service"
  rescue GRPC::BadStatus => e
    abort "ERROR: #{e.message}"
  end
end

main
