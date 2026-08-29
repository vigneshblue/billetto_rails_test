class Event < ApplicationRecord
  validates :event_id, presence: true, uniqueness: true
  validates :title, presence: true

  scope :ordered, -> { order(start_date: :asc) }

  def upvotes_count
    BillettoEvent.votes_count(event_id)[:upvotes]
  end

  def downvotes_count
    BillettoEvent.votes_count(event_id)[:downvotes]
  end
end
