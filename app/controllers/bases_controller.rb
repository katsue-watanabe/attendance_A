class BasesController < ApplicationController
  before_action :set_base, only: [:index, :show, :edit_base, :update_base, :destroy]
  
  def index
    @bases = Base.all
  end

  def show
  end

  def new
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '拠点を追加しました。'
      redirect_to @base
    else
      render :new
    end
  end

  def edit_base      
  end

  def update_base
    if @base.update_attributes(base_params)
      flash[:success] = "拠点の修正をしました。"
      redirect_to @base
    else
      render :index
    end
  end

  def destroy
    @base.destroy
    flash[:success] = "#{@base.name}を削除しました。"
    redirect_to base_url
  end


    private

      def base_params
        params.require(:base).permit(:base_id, :base_name, :base_type)
      end

      def set_base
        @base = Base.find_by(params[:branch])
      end
end
