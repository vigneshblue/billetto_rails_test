class Event < ApplicationRecord
  validates :event_id, presence: true, uniqueness: true
  validates :title, presence: true

  scope :ordered, -> { order(start_date: :asc) }

  def upvotes_count
    0
  end

  def downvotes_count
    0
  end
end
