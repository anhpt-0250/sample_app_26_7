class PasswordResetsController < ApplicationController
  before_action :find_user, :valid_user, :check_expiration,
                only: %i(edit update)
  def new; end

  def edit; end

  def create
    @user = User.find_by email: params.dig(:password_reset, :email)&.downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "please_check_reset"
      redirect_to root_path
    else
      flash.now[:danger] = t "invalid_email"
      render :new
    end
  end

  def update
    if User.password_params(params)[:password].empty?
      @user.errors.add :password, t("error")
      render :edit
    elsif @user.update User.password_params(params)
      log_in @user
      @user.update_column :reset_digest, nil
      flash[:success] = t "reset_success"
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def find_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:warning] = t "not_found_user"
    redirect_to root_path
  end

  def valid_user
    return if @user.activated && @user.authenticated?(:reset, params[:id])

    flash[:warning] = t "user_inactivated"
    redirect_to root_path
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = "reset_expired"
    redirect_to new_password_reset_url
  end
end
