class Billetto::Client
  BASE_URL = "https://billetto.dk/api/v3"

  def self.list_public_events limit=100
    params = { limit: limit }
    event_id = Event.last&.event_id
    params['after'] = event_id if event_id
    response = connection.get("public/events", params)
    if response.success?
      response_body = JSON.parse(response.body)
      [response_body["data"], response_body["has_more"]]
    else
      Rails.logger.error("Billetto API request failed: status=#{response.status}")
      raise "Billetto API request failed: #{response.status}"
    end
  end

  private

    def self.connection
      Faraday.new(url: BASE_URL) do |builder|
        builder.headers['accept'] = 'application/json'
        builder.headers['Api-Keypair'] = Rails.application.credentials.billetto_api_keypair
        builder.options.open_timeout = 5
        builder.options.timeout = 10
      end        
    end
end