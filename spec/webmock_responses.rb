module WebmockResponses
    # this module contains sample responses used by the webmock gem
    # This will allow us to test the behavior of the command line utility without actually making a real API request.
    # all sample responses were copied from the actual vPIC API

    def self.api_response_brief
        {
            "Count": 3,
            "Message": "Results returned successfully. NOTE: Any missing decoded values should be interpreted as NHTSA does not have data on the specific variable. Missing value should NOT be interpreted as an indication that a feature or technology is unavailable for a vehicle.",
            "SearchCriteria": "VIN:3AKJHHDR1KSKX6688",
            "Results": [ 
            {
                "Value": "FREIGHTLINER",
                "ValueId": "450",
                "Variable": "Make",
                "VariableId": 26
            },
            {
                "Value": nil,
                "ValueId": "",
                "Variable": "Series",
                "VariableId": 34
            },
            {
            "Value": "0",
            "ValueId": "0",
            "Variable": "Error Code",
            "VariableId": 143
            },
            ]
        }
    end

    def self.api_response_wrong_vin
        {
            "Count": 1,
            "Message": "Results returned successfully. NOTE: Any missing decoded values should be interpreted as NHTSA does not have data on the specific variable. Missing value should NOT be interpreted as an indication that a feature or technology is unavailable for a vehicle.",
            "SearchCriteria": "VIN:3AKJHHDR1KSKX6688",
            "Results": [ 
            {
                "Value": "6,7,11,400",
                "ValueId": "6,7,11,400",
                "Variable": "Error Code",
                "VariableId": 143
            },
            {
                "Value": "Invalid character(s): 3:O;",
                "ValueId": "",
                "Variable": "Additional Error Text",
                "VariableId": 156
            },
            {
                "Value": "6 - Incomplete VIN; 7 - Manufacturer is not registered with NHTSA for sale or importation in the U.S. for use on U.S roads; Please contact the manufacturer directly for more information; 11 - Incorrect Model Year - Position 10 does not match valid model year codes (I, O, Q, U, Z, 0). Decoded data may not be accurate.; 400 - Invalid Characters Present",
                "ValueId": "",
                "Variable": "Error Text",
                "VariableId": 191
            },
            ]
        }
    end

    def self.api_response_http_error_code
        {
            "message": "No HTTP resource was found that matches the request URI 'https://backend-vpic-api.nhtsa.gov/api/vehicles/wrong-api-endpoint/1AKJHHDR3KSKX6689?format=json",
            "messageDetail": "No action was found on the controller 'Vehicles' that matches the name 'wrong-api-endpoint"
        }
    end

    def self.api_response
        {
            "Count": 12,
            "Message": "Results returned successfully. NOTE: Any missing decoded values should be interpreted as NHTSA does not have data on the specific variable. Missing value should NOT be interpreted as an indication that a feature or technology is unavailable for a vehicle.",
            "SearchCriteria": "VIN:3AKJHHDR3KSKX6689",
            "Results": [
                {
                    "Value": "",
                    "ValueId": "",
                    "Variable": "Suggested VIN",
                    "VariableId": 142
                },
                {
                    "Value": "0",
                    "ValueId": "0",
                    "Variable": "Error Code",
                    "VariableId": 143
                },
                {
                    "Value": "",
                    "ValueId": "",
                    "Variable": "Possible Values",
                    "VariableId": 144
                },
                {
                    "Value": nil,
                    "ValueId": "",
                    "Variable": "Additional Error Text",
                    "VariableId": 156
                },
                {
                    "Value": "0 - VIN decoded clean. Check Digit (9th position) is correct",
                    "ValueId": "",
                    "Variable": "Error Text",
                    "VariableId": 191
                },
                {
                  "Value": "3AKJHHDR*KS",
                  "ValueId": "",
                  "Variable": "Vehicle Descriptor",
                  "VariableId": 196
              },
              {
                  "Value": "FREIGHTLINER",
                  "ValueId": "450",
                  "Variable": "Make",
                  "VariableId": 26
              },
              {
                  "Value": "DAIMLER TRUCKS NORTH AMERICA LLC",
                  "ValueId": "1024",
                  "Variable": "Manufacturer Name",
                  "VariableId": 27
              },
              {
                  "Value": "Cascadia",
                  "ValueId": "2501",
                  "Variable": "Model",
                  "VariableId": 28
              },
              {
                  "Value": nil,
                  "ValueId": "",
                  "Variable": "Series",
                  "VariableId": 34
              },
              {
                  "Value": nil,
                  "ValueId": "",
                  "Variable": "Series2",
                  "VariableId": 110
              },
              {
                  "Value": "Truck-Tractor",
                  "ValueId": "66",
                  "Variable": "Body Class",
                  "VariableId": 5
              },
              {
                "Value": "0",
                "ValueId": "0",
                "Variable": "Error Code",
                "VariableId": 143
              },
            ]
          }
    end

end