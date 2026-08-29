class User < ApplicationRecord
  validates :clerk_user_id, presence: true, uniqueness: true

  def user_id
    clerk_user_id
  end
end
