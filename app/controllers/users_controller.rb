class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)
  before_action :load_user, except: %i(index new create)

  def show
    @microposts = @user.microposts.page(params[:page])
      .per 5
    if current_user.following? @user
      @relationships = current_user.active_relationships
        .find_by followed_id: @user.id
    else
      @relationships = current_user
        .active_relationships.build
    end
  end

  def index
    @users = User.show_user
     .page(params[:page])
     .per 10
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = "sign success"
      redirect_to root_url
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new"
    end
  end

  def edit;end

  def update
    if @user.update_attributes user_params
      flash[:success] = "profile_updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = "user deleted"
    else
      flash[:danger] = "sign up not found"
    end
    redirect_to users_url
  end

  def following
    @title = "following"
    @users = @user.following.page(params[:page])
      .per 5
    render "show_follow"
  end

  def followers
    @title = "followers"
    @users = @user.followers.page(params[:id])
      .per 5
    render "show_follow"
  end

  private

  def user_params
    params.require(:user)
      .permit :name, :email, :password, :password_confirmation
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user.present?
    flash[:danger] = "sign up not found"
    redirect_to signup_path
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = "please login"
    redirect_to login_url
  end

  def correct_user
    @user = User.find_by id: params[:id]
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
