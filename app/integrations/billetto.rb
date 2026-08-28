class Billetto
  def self.call url=nil
    last_event_id = Event.last&.event_id
    after_param = "after=#{last_event_id}&" if last_event_id
    url = url || "https://billetto.dk/api/v3/public/events?#{after_param}limit=100"

    puts "fetching response"
    response = Faraday.new(
      url: url,
      headers: { "accept": "application/json", "Api-Keypair": Rails.application.credentials.billetto_api_keypair },
    ).get

    puts "fetched response"
    response = JSON.parse(response.body)
    data = response["data"]

    data.each do |event|
      Event.create!(
        event_id: event["id"],
        title: event["title"],
        description: event["description"],
        start_date: event["startdate"],
        image_url: event["image_link"],
        event_url: event["url"],
        country: event["location"]["country"]
      )
    end

    has_more = response["has_more"]
    next_url = response["next_url"]
    if has_more
      self.call next_url
    else
      puts "Ended"
    end
  end
end