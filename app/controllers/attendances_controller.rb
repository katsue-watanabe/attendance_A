class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overwork_notice, :edit_attendance_change, :update_attendance_change, :update_month_request, :edit_one_month_approval, :log_page]  
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :set_attendance, only: [:update, :edit_overwork, :update_overwork, :edit_overwork_notice]
  before_action :set_one_month, only: [:edit_one_month, :log_page]
  before_action :set_superior, only: [:edit_one_month, :update_one_month, :edit_overwork, :update_overwork, :update_month_request]
 
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
   
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end      
    end
    redirect_to @user
  end
 #勤怠変更
  def edit_one_month        
  end

  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)    
      end      
    end    
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])       
  end

  #勤怠変更の承認
  def edit_attendance_change                     
    @change_attendances = Attendance.where(superior_attendance_change_confirmation: @user.id, attendance_change_status: "申請中").order(:user_id, :worked_on).group_by(&:user_id)
  end

  def update_attendance_change
    attendance_change_params.each do |id, item|
      attendance = Attendance.find(id)
      if attendance_change_params[id][:change_check]
        if attendance_change_params[id][:superior_attendance_change_approval_confirmation] == "承認"
          attendance.attendance_change_check_status = "勤怠変更承認済"
          attendance.superior_attendance_change_confirmation = nil
        elsif overwork_notice_params[id][:superior_attendance_change_approval_confirmation] == "否認"
          attendance.attendance_change_check_status = "勤怠変更否認済"
          attendance.superior_attendance_change_confirmation = nil 
        else overwork_notice_params[id][:superior_attendance_change_approval_confirmation] == "なし"
          attendance.attendance_change_check_status = "勤怠変更なし"
          attendance.superior_attendance_change_confirmation = nil
        end
      else
        flash[:danger] = "承認確認のチェックを入れてください。"        
      end
      attendance.update(item)
        flash[:success] = "勤怠変更申請の承認結果を送信しました。"       
    end
  end

   #残業申請
  def edit_overwork
    @user = User.find(params[:user_id])  
  end

  def update_overwork
    @user = User.find(params[:user_id])                         
    if @attendance.update(overwork_params)
      flash[:success] = "#{@user.name}の残業を申請しました。"
    else
      flash[:danger] = "#{@user.name}残業申請の送信は失敗しました。"
    end
    redirect_to user_url(@user)        
  end

  #残業申請の承認
  def edit_overwork_notice
    @user = User.find(params[:id])                 
    @overwork_attendances = Attendance.where(superior_confirmation: @user.id, overwork_status: "申請中").order(:user_id, :worked_on).group_by(&:user_id)
    # @attendances = Attendance.overwork_notice_info(@user)
  end

  def update_overwork_notice
    overwork_notice_params.each do |id, item|
      attendance = Attendance.find(id)
      if overwork_notice_params[id][:is_check]
        if overwork_notice_params[id][:superior_notice_confirmation] == "承認"
          attendance.overwork_status = "残業承認済"
          attendance.superior_confirmation = nil
        elsif overwork_notice_params[id][:superior_notice_confirmation] == "否認"
          attendance.overwork_status = "残業否認済"
          attendance.superior_confirmation = nil 
        else overwork_notice_params[id][:superior_notice_confirmation] == "なし"
          attendance.overwork_status = "残業なし"
          attendance.superior_confirmation = nil
        end
      else
        flash[:danger] = "承認確認のチェックを入れてください。"        
      end
      attendance.update(item)
        flash[:success] = "残業申請の承認結果を送信しました。"       
    end
  end
  
  def edit_month_request
  end

  #1ヶ月分の勤怠申請    
  def update_month_request 
    @attendance = @user.attendances.find_by(worked_on: params[:attendance][:day])        
    if @attendance.update(month_request_params)
      flash[:success] = "#{@user.name}の1か月分の申請をしました。"
    else
      flash[:danger]= "所属長を選択してください。"
    end
    redirect_to user_url(@user)        
  end

   #所属長の承認
  def edit_one_month_approval                    
    @month_attendances = Attendance.where(superior_month_notice_confirmation: @user.id, one_month_approval_status: "申請中").order(:user_id, :worked_on).group_by(&:user_id)   
  end

  def update_one_month_approval
    month_approval_params.each do |id, item|
      attendance = Attendance.find(id)
      if month_approval_params[id][:approval_check]
        if month_approval_params[id][:superior_month_approval_confirmation] == "承認"
          attendance.one_month_approval_check_status = "承認済"
          attendance.one_month_approval_status = nil
        else month_approval_params[id][:superior_month_approval_confirmation] == "否認"
          attendance.one_month_approval_check_status = "否認済"
          attendance.one_month_approval_status = nil       
        end      
      else
        flash[:danger] = "承認確認のチェックを入れてください。"        
      end
      attendance.update(item)
        flash[:success] = "勤怠申請の承認結果を送信しました。"       
    end
  end

  def list_of_employees
    @users = User.all.includes(:attendances)
  end

  def log_page
    @attendances = @user.attendances.where(attendance_change_check_status: "勤怠変更承認済").order(:user_id, :worked_on).group_by(&:user_id)
  end

  private
  
    def set_attendance
      @attendance = Attendance.find(params[:id])      
    end

    def set_superior
      @superior = User.where(superior:true).where.not(id:current_user.id)
    end
    
    def attendances_params
      params.require(:user).permit(attendances: [:restarted_at, :refinished_at, :next_day, :note, :superior_attendance_change_confirmation, :attendance_change_status])[:attendances]
    end

    def attendance_change_params
      params.require(:user).permit(attendances: [:restarted_at, :refinished_at, :note, :change_check, :superior_attendance_change_approval_confirmation,  :attendance_change_check_status])[:attendances]
    end

    def overwork_params
      params.require(:attendance).permit(:overwork_end_time, :overwork_next_day, :process_content, :superior_confirmation, :overwork_status)
    end

    def overwork_notice_params
      params.require(:user).permit(attendances: [:overwork_end_time, :designated_work_end_time, :is_check, :process_content, :superior_notice_confirmation])[:attendances]
    end
    
    def month_request_params
      params.require(:attendance).permit(:superior_month_notice_confirmation, :one_month_approval_status)
    end
    
    def month_approval_params
      params.require(:user).permit(attendances: [:superior_month_approval_confirmation, :approval_check, :one_month_approval_check_status])[:attendances]
    end
end
