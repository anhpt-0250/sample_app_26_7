class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :find_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def show
    @page, @microposts = pagy @user.microposts, limit: Settings.pagy.items
  end

  def index
    @pagy, @users = pagy User.ordered_by_name, limit: Settings.pagy.items
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "please_check"
      redirect_to root_url, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "profile_updated"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "deleted"
    else
      flash[:danger] = t "delete_fail"
    end
    redirect_to users_path
  end

  def following
    @title = "Following"
    @pagy, @users = pagy @user.following, items: 10
    render :show_follow
  end

  def followers
    @title = "Followers"
    @pagy, @users = pagy @user.followers, items: 10
    render :show_follow
  end

  private
  def user_params
    params.require(:user).permit User::ATTRIBUTES_PERMITTED
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "not_found_user"
    redirect_to root_path
  end

  def correct_user
    return if current_user? @user

    flash[:error] = t "you_cannot"
    redirect_to root_path
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
