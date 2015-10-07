class UsersController < ApplicationController
  include UsersHelper
  # For devise
  before_filter :authenticate_user!
  # For role_model
  load_and_authorize_resource

  def index
    @user = current_user
    if (@user.has_role? :admin)
      @users = User.all
    else
      @users = User.where(:id => @user.id)
    end
  end

  def new
    # Add the default role
    @user.roles = [:member]
  end

  def create
    # Create a new User based on the parameters received
    @user = User.new(user_params)
    # Add the selected role
    @user.roles = [params[:role]]
    # Save the new User
    if @user.save
      redirect_to @user
    else
      render 'new'
    end
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    @user = User.find(params[:id])
    @user.roles = [params[:role]]
    if @user.update(user_params)
      redirect_to @user
    else
      render 'edit'
    end
  end

  def edit
  end

  def destroy
  end

  def show
  end

  def me
    @user = current_user
  end

  private
    def user_params
        params.require(:user).permit(:username, :email, :first_name, :last_name, :password, :picture)
    end

end
