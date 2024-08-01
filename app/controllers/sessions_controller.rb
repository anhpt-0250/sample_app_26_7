class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate params.dig(:session, :password)
      handle_success_login user
    else
      handle_fail_login
    end
  end

  def destroy
    log_out
    redirect_to login_path
  end

  private

  def handle_success_login user
    forwarding_url = session[:forwarding_url]
    reset_session
    log_in user
    params.dig(:session, :remember_me) == "1" ? remember(user) : forget(user)
    redirect_to forwarding_url || user
  end

  def handle_fail_login
    flash.now[:danger] = t "invalid"
    render :new, status: :unprocessable_entity
  end
end
