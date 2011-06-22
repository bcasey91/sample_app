class UsersController < ApplicationController

  before_filter :authenticate, :only => [:index, :edit, :update, :destroy]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy
  before_filter :user_okay,    :only => [:new, :create]

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def new
    @user = User.new
    @title = "Sign up now!"  
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Jungle"
      redirect_to @user 
    else
      @title = "Sign up"
      @user[:password] = ""
      @user[:password_confirmation] = ""
      render 'new'
    end
  end

  def edit
    @title = "Edit user"
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    if User.find(params[:id])==current_user
      flash[:notice] = "Admin users cannot delete themselves."
      redirect_to root_path
    else
      User.find(params[:id]).destroy
      flash[:success] = "User destroyed"
      redirect_to users_path
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def user_okay
      redirect_to(root_path) unless current_user.nil?
    end

end
