class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }

   # 出勤時間が存在しない場合、退勤時間は無効
  validate :refinished_at_is_invalid_without_a_restarted_at
  

  def refinished_at_is_invalid_without_a_restarted_at
    errors.add(:started_at, "が必要です") if restarted_at.blank? && refinished_at.present?
  end

  
  
  # def self.overwork_notice_info(user)
  #   self.joins(:user).select('attendances.*, users.name, user.designated_work_end_time')
  #     .where(superior_confirmation: user.id, overwork_status: "申請中").order(:user_id, :worked_on).group_by(&:user_id)
  # end
end
