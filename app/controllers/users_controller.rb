class UsersController < ApplicationController
  before_action :logged_in_user, only: [:update, :edit, :index, :destroy]
  before_action :correct_user,   only: [:update, :edit]
  before_action :check_if_admin, only: :destroy

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated? 
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    #@user = User.find(params[:id])
  end

  def update
    #@user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user
      flash[:success] = 'Your profile is successfully updated'
    else
      render :edit
    end
  end

    def destroy
        User.find(params[:id]).delete 
        flash[:success] = "User id:#{params[:id]} was successfully deleted"
        redirect_to :index
    end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
    
    
    #before filters

    #confirms a logged_in user
    def logged_in_user
      unless  logged_in?
        store_location
        flash[:danger] = "Please log in first."
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url unless current_user?(@user)
    end

    def check_if_admin
      redirect_to root_url unless current_user.admin?
    end
end 
