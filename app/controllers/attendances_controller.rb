class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overwork_notice]  
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :set_attendance, only: [:update, :edit_overwork, :update_overwork, :edit_overwork_notice]
  before_action :set_one_month, only: :edit_one_month
  before_action :set_superior, only: [:edit_one_month, :edit_overwork, :update_overwork]
 
  
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

  def edit_overwork
    @user = User.find(params[:user_id])  
  end

  def update_overwork
    @user = User.find(params[:user_id])    
    @superior = User.where(superior: true).where.not(id: current_user.id)                       
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
    @attendances = Attendance.where(superior_confirmation: @user.id, overwork_status: "申請中").order(:user_id, :worked_on).group_by(&:user_id)
    # @attendances = Attendance.overwork_notice_info(@user)
  end

  def list_of_employees
    @users = User.all.includes(:attendances)
  end

  private
  
    def set_attendance
      @attendance = Attendance.find(params[:id])      
    end
    
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :next_day, :note, :superior_confirmation])[:attendances]
    end

    def overwork_params
      params.require(:attendance).permit(:overwork_end_time, :overwork_next_day, :process_content, :superior_confirmation, :overwork_status)
    end

    def set_superior
      @superior = User.where(superior:true).where.not(id:current_user.id)
    end
end
