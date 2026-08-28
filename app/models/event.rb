class Event < ApplicationRecord
  validates :event_id, presence: true, uniqueness: true
  validates :title, presence: true

  scope :ordered, -> { order(start_date: :asc) }
end
