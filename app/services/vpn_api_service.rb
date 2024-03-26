module VpnApiService
  def self.check_ip(ip)
    cache_key = "ip_check_#{ip}"
    cached_response = $redis.get(cache_key)

    return JSON.parse(cached_response) if cached_response

    response = HTTParty.get("https://vpnapi.io/api/#{ip}?key=#{ENV['VPNAPI_KEY']}")

    if response.success?
      parsed_response = response.parsed_response
      $redis.setex(cache_key, 24.hours.to_i, parsed_response.to_json)
      parsed_response
    else
      error_message = response.parsed_response['error'] rescue 'Unidentified error'
      Rails.logger.error "VpnApiService Error: #{error_message}"
      default_response
    end
  rescue => e
    Rails.logger.error "Error fetching IP data: #{e.message}"
    default_response
  end

  def self.default_response
    {
      "security" => { "vpn" => false, "proxy" => false, "tor" => false, "relay" => false },
      "location" => { },
      "network" => { }
    }
  end
end
