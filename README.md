# Vinfly

Vinfly is a command line utility, written in Ruby, that accepts a VIN number and prints out information on a Vehicle and its specification. It retrieves information from [NHTSA's vPIC API](https://vpic.nhtsa.dot.gov/api/).

## Live Demo

You can test the utility on Replit: **[https://replit.com/@Cvrsor/vinfly](https://replit.com/@Cvrsor/vinfly#main.rb)**  
Hit the 'Play' icon to start the VM. You can then enter any **vinfly** commands at the prompt:

```ruby
bundle exec vinfly 3AKJHHDR3KSKX6689 --sparse
```
_(Replit VMs can sometimes be slow. The CLI performs better when installed locally)_

## Installation

The Vinfly command line utility is packaged as a ruby gem. To install, simply add this line to your application's Gemfile:

```ruby
gem 'vinfly', git: 'https://github.com/cvrsor/vinfly'
```

And then execute:

```ruby
bundle install
```

#### Prerequisites
Ruby version 2 or higher. Tested with Ruby v.3.1.2p20.

## Usage
```ruby
bundle exec vinfly [VIN_NUMBER]
```

Run `bundle exec vinfly help` to view the CLI's help notes and available options:

#### Options:
* `--raw` output the raw JSON response of the API
* `--fields 'field1,/field2/'` output the results of the fields that match the name or regular expression provided to the argument
* `--sparse` only output fields that have data in them and aren't empty or null
* `--meta` output how many fields and results were returned to the response
* `--yaml` output the results in the YAML format
* `--service` run a gRPC service

#### Examples:
Simple form:  
`bundle exec vinfly 3AKJHHDR3KSKX6689`

Use the --fields option to display two specific fields:  
`bundle exec vinfly 3AKJHHDR3KSKX6689 --fields 'Vehicle Descriptor,Make'`

Use the --fields option with regular expressions. The following command will display any fields that contain the word 'Vehicle', and fields that contain the word 'make' (case insensitive - note the /i switch):  
`vinfly 3AKJHHDR3KSKX6689 --fields '/Vehicle/,/make/i'`

Display fields that aren't empty or null:  
`bundle exec vinfly 3AKJHHDR3KSKX6689 --sparse`

## gRPC service

You can run the command Line utility as a gRPC service through the `--service` option.
```ruby
bundle exec vinfly --service
```
#### Options:
* `--port 5002` specify the network port the gRPC server is listening on (default 5001)

To test the gRPC service, start the server and run the test client:
```ruby
bundle exec test_client.rb [VIN_NUMBER]
```
The gRPC server uses a [Google::Protobuf::Struct](https://developers.google.com/protocol-buffers/docs/reference/csharp/class/google/protobuf/well-known-types/struct) to send the API's JSON response. The test_client.rb will output the number of results received: `Received 136 fields from gRPC service`.

#### Testing the gRPC service on Replit
To test the gRPC service, start the server by running the `bundle exec vinfly --service` command in a **Shell** window. Then open a new **Shell* tab, and run the client command: `bundle exec test_client.rb 3H3V532C0LR431008`. A Webview tab may open when you start the server - pls ignore this window.

## Source code notes

The gem has minimal external dependencies, specifically: the [Thor](https://github.com/rails/thor) gem, an established command-line utility and the [grpc](https://grpc.io/docs/languages/ruby/quickstart/) gem used by the gRPC server and test client.

The CLI's main code is in [\lib\vinfly.rb](https://github.com/cvrsor/vinfly/blob/master/lib/vinfly.rb). 

API call methods and handling is done by the [ApiHelper module](https://github.com/cvrsor/vinfly/blob/master/lib/vinfly/api_helper.rb).  

The gRPC service uses protocol buffers defined in [vin.proto](https://github.com/cvrsor/vinfly/blob/master/protos/vin.proto) file, located in the **\protos** directory.

## Tests

Tests for the CLI are located in the [\spec](https://github.com/cvrsor/vinfly/tree/master/spec) directory. The `api_spec.rb` contains API tests, and the `cli_spec.rb` tests the utility's terminal output. 

The [`spec_helper.rb`](https://github.com/cvrsor/vinfly/blob/master/spec/spec_helper.rb) file contains HTTP requests stubs - mock API responses used in tests. This allows us to test the behavior of the command line utility without actually making real API requests.

You can run the tests using `rake spec` command, which outputs:

```rspec
ApiHelper
  returns correctly vPIC API's response
  outputs the response's error message, when the API request was not successful (non-2xx status code)
  outputs an error message when the API request times out

Vinfly gem
  has a version number

VinFly CLI
  displays all fields, when invoked with a VIN number and no arguments ->
  displays the fields that match the name(s) provided to the argument --fields
  displays the fields that match the regular expression(s) provided to the argument --fields
  only displays fields that have data in them and aren`t empty or null, when the --sparse argument is used
  outputs how many results were returned to the response, when the --meta argument is used
  outputs how many results were returned to the response, when the --meta argument is used together with the --fields argument
  outputs the results in the YAML format, when the --yaml argument is used
  outputs the raw JSON response of the API, when the --raw argument is used
  outputs the Error Text returned by the API, when an invalid VIN number is entered

Finished in 0.05372 seconds (files took 0.54704 seconds to load)
13 examples, 0 failures
```