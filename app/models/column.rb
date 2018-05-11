class Column < ApplicationRecord
  belongs_to :project

  validates :name, presence: true, uniqueness: { scope: :project }, length: { maximum: 40 }
end
