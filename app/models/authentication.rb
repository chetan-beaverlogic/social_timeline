class Authentication < ActiveRecord::Base
  belongs_to :user
  has_many :time_line_statuses, dependent: :destroy
end
