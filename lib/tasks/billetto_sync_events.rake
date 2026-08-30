namespace :billetto do
  desc "Sync public events from Billetto"
  task sync_events: :environment do
    SyncEventsJob.perform_now
  end
end