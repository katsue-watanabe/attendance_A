class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overwork_notice, :edit_attendance_change, :update_attendance_change, :update_month_request, :edit_one_month_approval]  
  before_action :set_user_user_id, only: [:update_overwork_notice, :update_one_month_approval, :log_page]
  before_action :logged_in_user, only: [:update, :edit_one_month, :log_page]
  before_action :set_attendance, only: [:update, :edit_overwork, :update_overwork, :edit_overwork_notice, :log_page]
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
        if item[:superior_attendance_change_confirmation].present?
           #指示者を選択している場合
          if item[:restarted_at].blank? && item[:refinished_at].present?
            flash[:danger] = "出社時間を入力してください。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          elsif item[:restarted_at].present? && item[:refinished_at].blank?
            flash[:danger] = "退社時間を入力してください。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          elsif item[:restarted_at].blank? && item[:refinished_at].blank?  
            flash[:danger] = "勤務時間がありません"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return        
          elsif item[:note].blank?
            flash[:danger] = "備考欄を記入して下さい。" 
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end #if end 指示者が選択された場合で、時間が記入されていて成功 
          attendance.update_attributes!(item)
          flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        else
          flash[:danger] = "所属長を選択してください。" 
        end
        redirect_to user_url(date: params[:date]) and return
      end
    end   
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])       
  end

  #勤怠変更の承認
  def edit_attendance_change                     
    @change_attendances = Attendance.where(superior_attendance_change_confirmation: @user.id, attendance_change_status: "勤怠変更申請中").order(:user_id, :worked_on).group_by(&:user_id)
  end

  def update_attendance_change
    attendance_change_params.each do |id, item|
      attendance = Attendance.find(id)
      if attendance_change_params[id][:change_check]
        if attendance_change_params[id][:superior_attendance_change_approval_confirmation] == "承認"
          attendance.attendance_change_check_status = "#{current_user.name}から勤怠変更承認済"
          attendance.attendance_change_status = nil
        elsif attendance_change_params[id][:superior_attendance_change_approval_confirmation] == "否認"
          attendance.attendance_change_status = "#{current_user.name}から勤怠変更否認済"
          attendance.superior_attendance_change_confirmation = nil 
        else attendance_change_params[id][:superior_attendance_change_approval_confirmation] == "なし"
          attendance.attendance_change_check_status = "#{current_user.name}から勤怠変更なし"
          attendance.attendance_change_status = nil
        end
      else
        flash[:danger] = "承認確認のチェックを入れてください。"        
      end
      attendance.update(item)
        flash[:success] = "勤怠変更申請の承認結果を送信しました。"       
    end
    redirect_to user_url(@user)
  end

   #残業申請
  def edit_overwork
    @user = User.find(params[:user_id])  
  end

  def update_overwork    
    @user = User.find(params[:user_id])                         
    if overwork_params[:superior_confirmation].present? 
      @attendance.update(overwork_params)
      flash[:success] = "#{@user.name}の残業を申請しました。"
    else
      flash[:danger] = "所属長を選択してください。"
    end
    redirect_to user_url(@user)        
  end

  #残業申請の承認
  def edit_overwork_notice
    @user = User.find(params[:id])                 
    @overwork_attendances = Attendance.where(superior_confirmation: @user.id, overwork_status: "残業申請中").order(:user_id, :worked_on).group_by(&:user_id)
  end

  def update_overwork_notice
    overwork_notice_params.each do |id, item|
      attendance = Attendance.find(id)
      if overwork_notice_params[id][:is_check]
        if overwork_notice_params[id][:superior_notice_confirmation] == "承認"
          attendance.overwork_approval_status = "#{current_user.name}から残業承認済"
          attendance.overwork_status = nil
        elsif overwork_notice_params[id][:superior_notice_confirmation] == "否認"
          attendance.overwork_approval_status = "#{current_user.name}から残業否認済"
          attendance.overwork_status = nil 
        else overwork_notice_params[id][:superior_notice_confirmation] == "なし"
          attendance.overwork_approval_status = "#{current_user.name}から残業なし"
          attendance.overwork_status = nil
        end
      else
        flash[:danger] = "承認確認のチェックを入れてください。"        
      end
      attendance.update(item)
        flash[:success] = "残業申請の承認結果を送信しました。"       
    end
    redirect_to user_url(@user)
  end
  
  def edit_month_request
  end

  #1ヶ月分の勤怠申請    
  def update_month_request 
    @attendance = @user.attendances.find_by(worked_on: params[:attendance][:day])        
    if month_request_params[:superior_month_notice_confirmation].present? 
      @attendance.update(month_request_params)
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
          attendance.one_month_approval_check_status = "#{current_user.name}から承認済"
          attendance.one_month_approval_status = nil
        else month_approval_params[id][:superior_month_approval_confirmation] == "否認"
          attendance.one_month_approval_check_status = "#{current_user.name}から否認済"
          attendance.one_month_approval_status = nil       
        end              
      else
        flash[:danger] = "承認確認のチェックを入れてください。"        
      end
      attendance.update(item)
        flash[:success] = "勤怠申請の承認結果を送信しました。"       
    end
    redirect_to user_url(@user)
  end

  def list_of_employees
    @users = User.all.includes(:attendances)
  end

  def log_page
    if params["select_year(1i)"].nil?
      @first_day = Date.current.beginning_of_month
    else
      @first_day = Date.parse("#{params["select_year(1i)"]}/#{params["select_month(2i)"]}/1")
    end
    #@attendances = @user.attendances.where(worked_on: {}, attendance_change_check_status: "承認済").order(:user_id, :worked_on).group_by(&:user_id)
    #@first_day = Date.current.beginning_of_month
    @last_day = @first_day.end_of_month   
    #@attendances = @user.attendances.where(worked_on: @first_day..@last_day).where(attendance_change_check_status: "勤怠変更承認済").order(:worked_on)
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day, superior_notice_confirmation: "承認").order(:worked_on)
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
