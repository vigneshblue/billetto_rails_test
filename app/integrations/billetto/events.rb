class Billetto::Events
  def self.create events_arr
    events_arr.each do |event|
      Event.find_or_initialize_by(event_id: event["id"]).tap do |e|
        e.title = event["title"]
        e.description = event["description"]
        e.start_date = event["startdate"]
        e.image_url = event["image_link"]
        e.event_url = event["url"]
        e.country = event.dig("location", "country")

        unless e.save
          Rails.logger.error("Failed to sync Billetto event #{event['id']}: #{e.errors.full_messages.join(', ')}")
        end
        
      end
    end
  end
end