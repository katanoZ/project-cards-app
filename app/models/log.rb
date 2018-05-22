class Log < ApplicationRecord
  belongs_to :project

  paginates_per 5
end
