class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }

   # 出勤時間が存在しない場合、退勤時間は無効
  #validate :finished_at_is_invalid_without_a_started_at
   
  # 出勤・退勤時間どちらも存在する時、翌日チェックがない時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
   # 出勤変更・退勤変更時間どちらも存在する時、翌日チェックがない時、出勤変更時間より早い退勤変更時間は無効
  validate :restarted_at_than_refinished_at_fast_if_invalid
  

  # def finished_at_is_invalid_without_a_started_at
  #   errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  # end
  
  def started_at_is_invalid_without_a_finished_at
    errors.add(:finished_at, "が必要です") if finished_at.blank? && starthed_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present? && !next_day.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end

  def restarted_at_than_refinished_at_fast_if_invalid
    if restarted_at.present? && refinished_at.present? && !next_day.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if restarted_at > refinished_at
    end
  end
  

  
  
  # def self.overwork_notice_info(user)
  #   self.joins(:user).select('attendances.*, users.name, user.designated_work_end_time')
  #     .where(superior_confirmation: user.id, overwork_status: "申請中").order(:user_id, :worked_on).group_by(&:user_id)
  # end
end
