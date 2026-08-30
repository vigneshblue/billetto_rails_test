class SyncEventsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("Starting Billetto events sync")

    sync_billetto_events

    Rails.logger.info("Finished Billetto events sync")
  end

  private

    def sync_billetto_events
      events_arr, has_more = Billetto::Client.list_public_events
      return if events_arr.blank?
      Billetto::Events.create events_arr
      sync_billetto_events if has_more
    end
end
