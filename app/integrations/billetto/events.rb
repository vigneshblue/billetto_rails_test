class Billetto::Events
  def self.create events_arr
    events_arr.each do |event|
      Event.create!(
        event_id: event["id"],
        title: event["title"],
        description: event["description"],
        start_date: event["startdate"],
        image_url: event["image_link"],
        event_url: event["url"],
        country: event.dig("location", "country")
      )
    end
  end
end