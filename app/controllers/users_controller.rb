class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      log_in @user
      flash[:success] = t "wel_app"
      redirect_to @user
    else
      flash[:danger] = t "error_signup"
      render :new
    end
  end

  def show
    @user = User.find_by id: params[:id]

    if @user
      redirect_to root_path
    else
      flash[:danger] = t "error_find_user"
      redirect_to signup_path
    end
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end
end
