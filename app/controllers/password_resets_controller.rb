class PasswordResetsController < ApplicationController
  before_action :find_user_email, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "email_sent"
      redirect_to root_url
    else
      flash.now[:danger] = t "email_not_found"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render :edit
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = t "pass_reset"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def find_user_email
    @user = User.find_by email: params[:email]

    return if @user
    flash[:danger] = t "not_find"
    redirect_to root_url
  end

  def valid_user
    unless (@user && @user.activated? &&
            @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = t "password_expired"
      redirect_to new_password_reset_url
    end
  end
end
