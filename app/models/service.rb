class Service < ActiveRecord::Base
  belongs_to :user

  scope :pocket, -> { find_by(provider: :pocket) }
end
