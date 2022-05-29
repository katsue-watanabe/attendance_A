class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }

  # 出勤時間が存在しない場合、退勤時間を無効
  validate :finished_at_is_invalid_without_a_started_at

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  # def self.overwork_notice_info(user)
  #   self.joins(:user).select('attendances.*, users.name, user.designated_work_end_time')
  #     .where(superior_confirmation: user.id, overwork_status: "申請中").order(:user_id, :worked_on).group_by(&:user_id)
  # end
end
