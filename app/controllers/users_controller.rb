class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :list_of_employees]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :set_one_month, only: :show

  def index
    @users = User.paginate(page: params[:page], per_page: 5)
  end

  def import
    User.import(params[:file])   
    redirect_to users_url 
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
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
      params.require(:user).permit(:name, :email, :department, :employee_number, :uid, :password, :basic_time, :designated_work_start_time, :designated_work_endt_time, :superior)
    end

    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end    
end
