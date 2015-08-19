class WelcomeController < ApplicationController
  def index
  end

  def landing
    @user = User.find(params[:id])
    #If the user is found
    @rooms = Room.where(:user_id => @user.id)
    #if is not show an error
  end
end
