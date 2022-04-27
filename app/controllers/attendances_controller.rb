class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :update_overwork]  
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_overwork, :update_overwork]
  before_action :set_one_month, only: :edit_one_month
 
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
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
    @attendance = Attendance.find(params[:id])      
  end

  def update_overwork
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])  
    if @attendance.update_attributes(overwork_params)
      flash[:success] = "{@user.name}の残業を申請しました。"
    else
      flash[:danger] = "{@user.name}残業申請の送信は失敗しました。"
    end
    redirect_to @user
  end

  def list_of_employees
    @users = User.all.includes(:attendances)
  end

  private    
    
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

    def overwork_params
      params.require(:attendances).permit(:overwork_end_time, :next_day, :process_content, :superior_confirmation)
    end
end