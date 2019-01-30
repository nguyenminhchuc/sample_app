class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :find_user_id, only: %i(edit show update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)

  def index
    @users = User.page(params[:page]).per Settings.num_page
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t "ple_check_mail"
      redirect_to root_url
    else
      flash[:danger] = t "error_signup"
      render :new
    end
  end

  def show
    if @user
      redirect_to root_path
    else
      flash[:danger] = t "error_find_user"
      redirect_to signup_path
    end
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "pro_update"
      redirect_to @user
    else
      flash[:danger] = t "profile_fail"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "u_delete"
      redirect_to users_url
    else
      flash[:danger] = t "del_fail"
    end
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def logged_in_user
    return false if logged_in?
    store_location
    flash[:danger] = t "ple_login"
    redirect_to login_url
  end

  def correct_user
    redirect_to root_url unless @user.current_user? current_user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def find_user_id
    @user = User.find_by id: params[:id]

    return if @user
    flash[:danger] = t "not_find"
    redirect_to root_url
  end
end
