class Column < ApplicationRecord
  belongs_to :project
  has_many :cards, -> { order(position: :desc) }, dependent: :destroy

  attr_accessor :operator

  acts_as_list scope: :project

  validates :name, presence: true, uniqueness: { scope: :project }, length: { maximum: 40 }

  after_create ColumnLogsCallbacks.new
  after_update ColumnLogsCallbacks.new
  after_destroy ColumnLogsCallbacks.new
end
