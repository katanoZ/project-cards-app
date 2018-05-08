class Project < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: true, length: { maximum: 140 }
  validates :summary, length: { maximum: 300 }
end
