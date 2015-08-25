class WelcomeController < ApplicationController
  include ApplicationHelper

  def index
  end

  def landing
    logger.info params.inspect
    if params[:landing_id] == 'dashboard' || params[:landing_id] == 'rooms' || params[:landing_id] == 'profile' || params[:landing_id] == 'settings'
      redirect_to '/' + params[:landing_id] + '/index'
    else if params[:landing_id] == 'landing'
      if is_number?(params[:room_id])
        @room = Room.find(params[:room_id])
        if user_signed_in?
          @join_url = root_path+'bbb/join/'+@room.id.to_s
        else
          @join_url = nil
        end
      else
        @room = nil
      end
      render 'landing_room'
    else
      begin
        if is_number?(params[:landing_id])
          @user = User.find_by!(id: params[:landing_id])
        else
          @user = User.find_by!(username: params[:landing_id])
        end
        #If the user is found
        @rooms = Room.where(:user_id => @user.id)
      rescue
        logger.info "Landing page not found"
        #if is not show an error
        raise ActionController::RoutingError.new('Landing page not Found')
        #render :file => 'public/404.html', :status => :not_found, :layout => false
      end
    end end
  end

  def about
  end

  def contact
  end

end
