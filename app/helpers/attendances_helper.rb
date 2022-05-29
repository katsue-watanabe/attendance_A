module AttendancesHelper

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    return false
  end

  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish, next_day)
    if next_day
      format("%.2f", (((finish - start) / 60) / 60.0) + 24)
    else
      format("%.2f", ((finish - start) / 60) / 60.0)
    end
  end
  
  def working_overwork_times(designated_work_end_time, overwork_end_time, overwork_next_day)            
    if overwork_next_day
      format("%.2f", (overwork_end_time.hour - designated_work_end_time.hour) + ((overwork_end_time.min - designated_work_end_time.min) / 60.0) + 24)
    else
      format("%.2f", (overwork_end_time.hour - designated_work_end_time.hour) + ((overwork_end_time.min - designated_work_end_time.min) / 60.0))
    end
  end
  
  #残業申請のステータス
  def overwork_status_text(status)
    case status
    when "申請中"
      "残業申請中"
    when "否認"
      "残業否認"
    when "承認"
      "残業承認"
    when "なし"
    else
    end
  end
end 