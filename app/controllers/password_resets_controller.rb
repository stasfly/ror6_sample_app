class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]



  def new #new           new_password_reset_path
  end

  def create #create            password_resets_path
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instruction"
      redirect_to root_path
    else
      flash[:warning] = "Email address not found"
      render :new
    end
  end
  
  def edit #edit         edit_password_reset_url(token)
  end

  def update #update            password_reset_path(token)
    if params[:user][:password].empty?
      @user.errors.add(:password, 'Cannot be empty')
      render :edit
    elsif @user.update(user_params)
      log_in(@user)
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password is reset"
      redirect_to @user
    else
      render :edit
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  
  def get_user
      @user = User.find_by(email: params[:email])
    end

    #Confirm the valid user
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired"
        redirect_to new_password_reset_url
      end
      false
    end
end
