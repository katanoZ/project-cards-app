class Card < ApplicationRecord
  belongs_to :assignee, class_name: 'User',
                        foreign_key: :assignee_id,
                        inverse_of: :assigned_cards
  belongs_to :project
  belongs_to :column

  validates :name, presence: true,
                   uniqueness: { scope: :project },
                   length: { maximum: 40 }
  validates :due_date, allow_nil: true, due_date_range: true
end
