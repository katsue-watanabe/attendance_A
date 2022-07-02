class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :list_of_employees]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :admin_impossible, only: :show
  before_action :set_one_month, only: :show

  def index
    @users = User.paginate(page: params[:page], per_page: 5)
  end  

  def import
   if params[:file].blank?
     flash[:danger]= "csvファイルを選択してください"
   else 
     User.import(params[:file]) 
     flash[:success] = "csvファイルをインポートしました。"    
   end
   redirect_to users_url
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count    
    @superior = User.where(superior: true).where.not(id: @user.id)
    @attendance = @user.attendances.find_by(worked_on: @first_day)
   # @user.attendancesは、Attendance.find_by(user_id: @user.id)
    if current_user.superior?      
      @overwork_sum = Attendance.includes(:user).where(superior_confirmation: current_user.id, overwork_status: "申請中").count
      @attendance_change_sum = Attendance.includes(:user).where(superior_attendance_change_confirmation: current_user.id, attendance_change_status: "申請中").count
      @one_month_approval_sum = Attendance.includes(:user).where(superior_month_notice_confirmation: current_user.id, one_month_approval_status: "申請中").count    
    end
    # csv出力    
    respond_to do |format|
      format.html 
      format.csv do |csv|
        send_attndances_csv(@attendances)
      end
    end   
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user 
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      flash[:danger] = "ユーザー情報を更新できません。"
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def list_of_employees
    @users = User.all.includes(:attendances)
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :department, :employee_number, :uid, :password, :basic_time, :designated_work_start_time, :designated_work_end_time)
    end

    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end
    
    def send_attndances_csv(attendances)
      # CSV.generateとは、対象データを自動的にCSV形式に変換してくれるCSVライブラリの一種
      csv_data = CSV.generate do |csv|
        # %w()は、空白で区切って配列を返します
        column_names = %w(日付 出勤時間 退勤時間)
        # csv << column_namesは表の列に入る名前を定義します。
        csv << column_names
        # column_valuesに代入するカラム値を定義します。
        attendances.each do |day|
          column_values = [
            l(day.worked_on, format: :short),
            day.restarted_at&.strftime("%H"),
            day.restarted_at&.strftime("%M"),
            day.restarted_at&.strftime("%H"),
            day.restarted_at&.strftime("%M")
          ]
        # csv << column_valueshは表の行に入る値を定義します。
          csv << column_values
        end
      end
      # csv出力のファイル名を定義します。
      send_data(csv_data, filename: "勤怠一覧.csv")
    end
end
