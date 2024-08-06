class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    @micropost.image.attach params.dig(:micropost, :image)
    if @micropost.save
      flash[:success] = t "micropost_created"
      redirect_to root_url
    else
      handle_create_failure
    end
  end

  def destroy
    if @micropost.destroy
      handle_destroy_success
    else
      flash[:danger] = t "deleted_fail"
      redirect_to root_url
    end
  end

  private
  def micropost_params
    params.require(:micropost).permit Micropost::POSTS_PERMITTED
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t "micropost_invalid"
    redirect_to request.referer || root_url
  end

  def handle_create_failure
    @pagy, @feed_items = pagy(current_user.feed, limit: Settings.pagy.items)
    render "static_pages/home"
  end

  def handle_destroy_success
    current_page = extract_current_page_from_referer
    total_posts = current_user.feed.count
    total_pages = calculate_total_pages(total_posts)
    current_page = total_pages if current_page > total_pages
    flash[:success] = t "micropost_deleted"
    redirect_to root_url(page: current_page)
  end

  def extract_current_page_from_referer
    (URI(request.referer).query || "").split("&").find do |param|
      param.include?("page")
    end&.split("=")&.last&.to_i || 1
  end

  def calculate_total_pages total_posts
    (total_posts / Settings.pagy.items.to_f).ceil
  end
end
