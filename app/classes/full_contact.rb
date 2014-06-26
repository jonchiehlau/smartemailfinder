require 'json'
require 'uri'
require 'cgi'

class FullContact
  API_ENDPOINT = "https://api.fullcontact.com/v2"

  def self.batch_call(emails)
    json = {
        "requests" => [
            *emails.map { |e| "#{API_ENDPOINT}/person.json?email=#{CGI.escape(e)}" }
        ]
    }.to_json

    call_url = URI.parse("#{API_ENDPOINT}/batch.json?apiKey=#{Rails.configuration.fullcontact_api_key}")

    http = Net::HTTP.new(call_url.host, call_url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(call_url.request_uri)
    request.add_field('Content-Type', 'application/json')
    request.body = json
    response = http.request(request)

    api_result = JSON.parse(response.body)

    puts api_result

    matched_results = {}
    retry_results = []
    if api_result["status"].to_i == 200 && api_result['responses']
      api_result['responses'].each_pair do |url, email_response|
        email = CGI.unescape(url.gsub "#{API_ENDPOINT}/person.json?email=", '')
        if email_response['status'].to_i == 200
          matched_results[email] = {}
          %w(facebook twitter linkedin).each do |type_id|
            profile_data = email_response['socialProfiles'].find { |profile| profile['typeId'] == type_id }
            matched_results[email][type_id.to_sym] = {:username => profile_data['username'], :url => profile_data['url']} if profile_data
          end

          matched_results.delete(email) if matched_results[email].empty?
        elsif email_response['status'].to_i == 202
          retry_results << email
        elsif email_response['status'].to_i == 403
          raise FullContactException.new("Usage limit exceeded. You may refresh the page to try again.")
        end
      end
    else
      raise FullContactException.new("Failed to communicate to FullContact API. Message was: #{api_result['message']}")
    end

    puts '==='
    puts matched_results
    puts '==='
    puts retry_results
    puts '==='

    return matched_results, retry_results
  end
end