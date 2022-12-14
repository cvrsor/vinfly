require 'spec_helper'

include ApiHelper

RSpec.describe "Vinfly gem" do
  it "has a version number" do
    expect(Vinfly::VERSION).not_to be nil
  end
end

RSpec.describe "VinFly CLI" do
    it 'displays all fields, when invoked with a VIN number and no arguments -> ' do
        expected_output = "\nField     \tValue\n-----     \t-----\nMake      \tFREIGHTLINER\nSeries    \t\nError Code\t0\n"
        expect do
            Vinfly::CLI.new.invoke(:decode_vin, ['3AKJHHDR1KSKX6688'], {})
        end.to output(expected_output).to_stdout
    end

    it 'displays the fields that match the name(s) provided to the argument --fields' do
        expected_output = "\nField     \tValue\n-----     \t-----\nModel     \tCascadia\nBody Class\tTruck-Tractor\n"
        expect do
        Vinfly::CLI.new.invoke(:decode_vin, ['3AKJHHDR3KSKX6689'], {fields: 'Model,Body Class'})
        end.to output(expected_output).to_stdout
    end

    it 'displays the fields that match the regular expression(s) provided to the argument --fields' do
        expected_output = "\nField  \tValue\n-----  \t-----\nSeries \t\nSeries2\t\n"
        expect do
            Vinfly::CLI.new.invoke(:decode_vin, ['3AKJHHDR3KSKX6689'], {fields: '/series/i'})
        end.to output(expected_output).to_stdout
    end

    it 'only displays fields that have data in them and aren`t empty or null, when the --sparse argument is used' do
        expected_output = "\nField     \tValue\n-----     \t-----\nMake      \tFREIGHTLINER\nError Code\t0\n"
        expect do
            Vinfly::CLI.new.invoke(:decode_vin, ['3AKJHHDR1KSKX6688'], {sparse: true})
        end.to output(expected_output).to_stdout
    end

    it 'outputs how many results were returned to the response, when the --meta argument is used' do
        expected_output = "Total results: 3\n"
        expect do
            Vinfly::CLI.new.invoke(:decode_vin, ['3AKJHHDR1KSKX6688'], {meta: true})
        end.to output(expected_output).to_stdout
    end


    it 'outputs how many results were returned to the response, when the --meta argument is used together with the --fields argument' do
        expected_output = "Total results: 3\nFiltered results: 1\n"
        expect do
            Vinfly::CLI.new.invoke(:decode_vin, ['3AKJHHDR1KSKX6688'], {meta: true, fields: 'Make'})
        end.to output(expected_output).to_stdout
    end

    it 'outputs the results in the YAML format, when the --yaml argument is used' do
        expected_output = "---\nMake: FREIGHTLINER\nSeries: ''\nError Code: '0'\n"
        expect do
            Vinfly::CLI.new.invoke(:decode_vin, ['3AKJHHDR1KSKX6688'], {yaml: true})
        end.to output(expected_output).to_stdout
    end

    it 'outputs the raw JSON response of the API, when the --raw argument is used' do
        expected_output = {"Count": 3,"Message": "Results returned successfully. NOTE: Any missing decoded values should be interpreted as NHTSA does not have data on the specific variable. Missing value should NOT be interpreted as an indication that a feature or technology is unavailable for a vehicle.","SearchCriteria": "VIN:3AKJHHDR1KSKX6688","Results": [ {"Value": "FREIGHTLINER","ValueId": "450","Variable": "Make","VariableId": 26},{"Value": nil,"ValueId": "","Variable": "Series","VariableId": 34},{"Value": "0","ValueId": "0","Variable": "Error Code","VariableId": 143}]}.to_json + "\n"
        expect do
            Vinfly::CLI.new.invoke(:decode_vin, ['3AKJHHDR1KSKX6688'], {raw: true})
        end.to output(expected_output).to_stdout
    end

    it 'outputs the Error Text returned by the API, when an invalid VIN number is entered' do
        expected_output = "the API returned the following 6 errors/messages:\n6 - Incomplete VIN\n7 - Manufacturer is not registered with NHTSA for sale or importation in the U.S. for use on U.S roads\nPlease contact the manufacturer directly for more information\n11 - Incorrect Model Year - Position 10 does not match valid model year codes (I, O, Q, U, Z, 0). Decoded data may not be accurate.\n400 - Invalid Characters Present\nInvalid character(s): 3:O\n"
        expect do
            Vinfly::CLI.new.invoke(:decode_vin, ['1AKJHHDR3KSKX6689'], {})
        end.to output(expected_output).to_stdout
    end

end