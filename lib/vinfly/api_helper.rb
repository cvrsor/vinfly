module ApiHelper
    #handles the vPIC API call, checks if there are returned error messages 

    def call_vpic_api(vin_number)

        url = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/#{vin_number}?format=json"
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.read_timeout = 5
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)        
        begin
            resp = http.request(request)
        rescue Timeout::Error, Errno::ECONNREFUSED
            # Handle connection errors
            puts "The request timed out or the connection was refused"
            return nil
        end
        
        
        #check if the API call was successful using the returned HTTP status code
        if resp.code.start_with?("2") == false
            display_api_request_errors(resp)
            return nil
        end
        
        #check if the API response has an error message related to the VIN number
        parsed_response = JSON.parse(resp.body)
        if response_has_error?(parsed_response)
            display_api_errors(parsed_response)
            return nil
        end
        return parsed_response
    end

private
    def response_has_error?(parsed_response)
        #the API returns a field named 'Error Code' with value "0" when the VIN number has been found,
        #...or several different Error Codes if there were any issues with the provided VIN number
        if parsed_response.has_key?('Results') && parsed_response['Results'].select{|r| r['Variable'] == 'Error Code'}.first['Value'] == "0"
            return false
        else
            return true
        end
    end

    def display_api_errors(parsed_response)
        #displays VIN number errors (API request returns a 2xx status code, but the response has error messages related to the VIN number)
        errors = []
        error_text = parsed_response['Results'].select{|r| r['Variable'] == 'Error Text'}.first
        if error_text.nil? == false && error_text['Value'].nil? == false
            if error_text['Value'].include?(';')
                errors = error_text['Value'].split(';').collect(&:strip)
            else
                errors = [error_text['Value']]
            end
        end

        additional_errors = []
        additional_error_text = parsed_response['Results'].select{|r| r['Variable'] == 'Additional Error Text'}.first
        if additional_error_text.nil? == false && additional_error_text['Value'].nil? == false
            if additional_error_text['Value'].include?(';')
                additional_errors = additional_error_text['Value'].split(';').collect(&:strip)
                errors = errors + additional_errors
            else
                errors.push([additional_error_text['Value']])
            end
        end

        puts "the API returned the following #{errors.length} errors/messages:"
        puts errors.join("\n")
    end
    
    def display_api_request_errors(resp)
        #displays API request errors (got a non-2xx HTTP status error code)
        #HTTP status error code        
        errors = []
        errors.push("An error occurred while requesting information from the vPIC API")

        if resp.message.nil? == false
            errors.push("#{resp.code} - #{resp.message}")
        end

        if resp.content_type == 'application/json'
            parsed_response = JSON.parse(resp.body)
            if parsed_response.has_key?('message')
                errors.push(parsed_response['message'])
            end
        else
            if resp.body.length < 500
                #some error messages return an HTML page 
                #(ex. got a 503 - Service Unavailable error message, that returned a large HTML page saying the service is undergoing maintenance)
                #checking for resp.body.length size to avoid displaying a large resp.body
                errors.push(resp.body)
                message = ": #{resp.body}"
            else
                #ignore longer body responses
            end
        end
        
        puts errors.join(': ')
    end
end #ApiHelper