class Base < ApplicationRecord
  validates :base_number, presence: true
  validates :base_branch, presence: true, uniqueness: true,  length: { maximum: 50 }
  validates :work_type, presence: true
end