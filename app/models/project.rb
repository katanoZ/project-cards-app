class Project < ApplicationRecord
  belongs_to :user

  paginates_per 9

  validates :name, presence: true, uniqueness: true
end
