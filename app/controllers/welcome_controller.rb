class WelcomeController < ApplicationController
  include ApplicationHelper

  def index
  end

  def landing
    if params[:id] == 'dashboard' || params[:id] == 'rooms'
      redirect_to '/' + params[:id] + '/index'
    else

    begin
      if is_number?(params[:id])
         @user = User.find_by!(id: params[:id])
      else
         @user = User.find_by!(username: params[:id])
      end
      #If the user is found
      @rooms = Room.where(:user_id => @user.id)
    rescue
      logger.info "Landing page not found"
      #if is not show an error
      raise ActionController::RoutingError.new('Landing page not Found')
      #render :file => 'public/404.html', :status => :not_found, :layout => false
    end
    end

  end

  def about
  end

  def contact
  end

end
