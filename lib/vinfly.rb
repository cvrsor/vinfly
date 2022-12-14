require "vinfly/version"
require 'vinfly/api_helper'
require 'thor'
require 'uri'
require 'net/http'
require 'json'
require 'yaml'

module Vinfly
  class CLI < Thor
    default_task :decode_vin
    include ApiHelper    

    desc "[VIN_NUMBER]", "decodes a vin number"
    long_desc <<-LONGDESC
      Vinfly is a utility that accepts a VIN number and prints out information on a Vehicle and its specification.\n
      > $ vinfly 3AKJHHDR3KSKX6689

      You can optionally specify a --fields option and only display fields that match the name or regular expression provided to the argument.
      Enter the --fields option as a comma-separated string 
      
      For example, the following command displays two specific fields:\n
      > $ vinfly 3AKJHHDR3KSKX6689 --fields 'Vehicle Descriptor,Make'

      You can also use regular expressions. The following command will display any fields that contain the word 'Vehicle', and fields that contain the word 'make' (case insensitive - note the /i switch): \n
      > $ vinfly 3AKJHHDR3KSKX6689 --fields '/Vehicle/,/make/i'
    LONGDESC
    option :raw, :type => :boolean, :default => false, :desc => "output the raw JSON response of the API"
    option :fields, :type => :string, :default => "", :desc => "output the results of the fields that match the name or regular expression provided to the argument"
    option :sparse, :type => :boolean, :default => false, :desc => "only output fields that have data in them and aren't empty or null"    
    option :meta, :type => :boolean, :default => false, :desc => "output how many fields and results were returned to the response"
    option :yaml, :type => :boolean, :default => false, :desc => "output the results in the YAML format"    
    option :service, :type => :boolean, :default => false, :desc => "run a gRPC service"
    option :debug, :type => :boolean, :default => false, :desc => "show debug info"
    def decode_vin(vin_number)
      puts "Decoding VIN #{vin_number}" if options['debug']
      
      #Call the API, parse the results response
      full_response = call_vpic_api(vin_number)
      if full_response.nil?        
        return true
      end
      if is_blank?(full_response['Results']) == true
        puts "No results found"
      end

      results = full_response['Results']

      #--fields option
      if is_blank?(options['fields']) == false
        results = self.filter_fields(results, options)
      end

      #--sparse option
      if options['sparse'] === true
        results = results.filter{|result| is_blank?(result['Value']) == false }
      end


      #Display results      
      #Determine output style
      output_style = 'tabular' #tabular is the default style, a tabbed table
      
      if options['raw'] && options['yaml']
        #if `--raw` and `--yaml` are both provided, whichever option comes later in the arguments should be preferred
        #comparing the index of both options in the argyments array (ARGV)
        if ARGV.index('--raw') > ARGV.index('--yaml')
          output_style = 'raw'
        else
          output_style = 'yaml'
        end
      elsif options['raw']
        output_style = 'raw'
      elsif options['yaml']
        output_style = 'yaml'
      else
        output_style = 'tabular'
      end
      
      if options['meta'] == true
        #--meta option should supersede other options
        output_style = 'meta'
      end

      puts "Output style: #{output_style}" if options['debug']
      if output_style == 'tabular'
        #first column is the Field name ('Variable' key)
        max_variable_length = 0
        #calculate the longest word's length to determine whitespace padding
        max_variable_length = results.map{|r| r['Variable'].to_s }.max_by(&:length).length
        #table headers.
        puts "\n" + "Field".ljust(max_variable_length) + "\t" + "Value" #https://apidock.com/ruby/v2_6_3/String/ljust
        puts "-----".ljust(max_variable_length) + "\t" + "-----"
        #table body
        results.each { |result|
          puts result['Variable'].ljust(max_variable_length) + "\t" + result['Value'].to_s
        }
      end

      if output_style == 'simple'
        results.each { |result|
          puts result['Variable'] + ":\t" + result['Value'].to_s
        }
      end

      if output_style == 'raw'
        puts full_response.to_json
      end

      if output_style == 'meta'
        puts "Total results: #{full_response['Results'].length}"
        if full_response['Results'].length != results.length
          #if a filter has been applied, such as --sparce or --fields, show the number of filtered results
          puts "Filtered results: #{results.length}"
        end
      end
      
      if output_style == 'yaml'
        puts Hash[results.map{ |result| [result['Variable'], result['Value'].to_s.strip] }].to_yaml
      end

    end #decode_vin task

    #----gRPC server-----
    #start server: bundle exec exe/vinfly --service
    #start client: bundle exec exe/test_client.rb [VIN NUMBER]

    this_dir = File.expand_path(File.dirname(__FILE__))
    lib_dir = File.join(this_dir, 'lib')
    $LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

    require 'grpc'
    require 'vin_services_pb'
    require 'google/protobuf/well_known_types'

    class GrpcServer < Decodevin::Vin::Service
      include ApiHelper
      def decode_vin(vin_req, _unused_call)
        puts "GrpcServer::decode_vin #{vin_req.vinnumber}"
        full_response = call_vpic_api(vin_req.vinnumber)
        #use Google::Protobuf::Struct to send the API's JSON response
        #Struct has custom JSON handling, as mentioned in the following reference doc: The JSON representation for Struct is JSON object.
        #https://developers.google.com/protocol-buffers/docs/reference/csharp/class/google/protobuf/well-known-types/struct
        Decodevin::VinReply.new(results: Google::Protobuf::Struct.from_hash(full_response))
      end
    end

    desc "run_grpc_service ", "runs gRPC server"
    option :service, :type => :boolean, :default => false, :desc => "run gRPC service"
    option :port, :type => :numeric, :default => 5001, :desc => "network port to run service"
    def run_grpc_service()
      port = options['port']
      puts "Starting gRPC server, port: #{port.to_s}"
      s = GRPC::RpcServer.new
      s.add_http2_port("0.0.0.0:#{port.to_s}", :this_port_is_insecure)
      s.handle(GrpcServer)
      # Runs the server with SIGHUP, SIGINT and SIGTERM signal handlers to
      #   gracefully shutdown.
      # User could also choose to run server via call to run_till_terminated
      s.run_till_terminated_or_interrupted([1, 'int', 'SIGTERM'])
    end #run_grpc_service task

private

    def filter_fields(results, options)
      # this method processes the field_names given as an array argument to the --fields option
      # filters results based on given conditions: fields that match the name or regular expression provided
      
      field_names = options['fields'].split(',') #the --fields argument is provided as a comma-separated string      
      field_names = field_names.select{|f| is_blank?(f) == false } #remove nil/empty values
      if field_names.length == 0
        return results
      end
      # STEP 1: gather all conditions
      conditions = []
      field_names.each { |field_name|
        regex = nil
        if field_name[0] == '/' && field_name[-1] == '/'
          #case 1: simple regex starting and ending with forward slash
          #example: --fields '/Series/' will return fields 'Series' and 'Series2'
          regex = Regexp.new(field_name[1..-2])
          puts "Regex: #{regex}" if options['debug']
        elsif field_name[0] == '/' && field_name[-1] != '/' && field_name.count('/') == 2
          #case 2: we have a regex with swiches
          #example: --fields '/series/i' will return fields 'Series' and 'Series2' - match is case insensitive because of the /i switch
          regex = eval(field_name)
          puts "Regex with switches: #{regex}" if options['debug']
        else
          #treat string as an exact match Regex
          #example: --fields '/Series/' will only return 'Series'
          regex = /^#{field_name.strip}$/
          puts "Exact match regex: #{regex}" if options['debug']
        end        
        conditions.push(regex)
      }

      # STEP 2: filter results
      puts "checking for #{conditions.length} conditions" if options['debug']
      return results.filter{ |result| 
        #if any of the conditions match this field, return true
        res = conditions.any? { |regex|
          if options['debug'] && regex.match?(result['Variable'])
            puts "Checking field: #{result['Variable']}, matches: #{regex.to_s}, result: #{regex.match?(result['Variable'])}"
          end
          regex.match?(result['Variable'])
        }
        res
      }
    end #filter_fields
    
    def is_blank?(x)
      x.nil? || x.empty?
    end
    
    def self.exit_on_failure?
      #setting to true, to stop execution if an error is thrown
      true
    end
  end #class CLI

  # class Error < StandardError; end
  # # Your code goes here...

end #Module
