class Base < ApplicationRecord
  validates :base_number, presence: true, uniqueness: true
  validates :base_branch, presence: true, uniqueness: true
  validates :work_type, presence: true
end