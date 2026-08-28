class User < ApplicationRecord
  validates :clerk_user_id, presence: true, uniqueness: true
end
