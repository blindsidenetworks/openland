class WelcomeController < ApplicationController
  include ApplicationHelper
  include BbbHelper

  def index
    logger.info params[:controller]+'/'+params[:action]
    logger.info params.inspect
  end

  def landing
    logger.info params[:controller]+'/'+params[:action]
    logger.info params.inspect
    if params[:landing_id] == 'dashboard' || params[:landing_id] == 'rooms'
      redirect_to '/' + params[:landing_id] + '/index'
    else
      begin
        if is_number?(params[:landing_id])
          @user = User.find_by!(id: params[:landing_id])
        else
          @user = User.find_by!(username: params[:landing_id])
        end
        #If the user is found then look for the room
        @rooms = Room.where(:user_id => @user.id)
        render "landing_"+landing_style, :layout => landing_style
        #render 'landing_'+landing_style # only works with nova
        #render 'landing_classic', :layout => 'classic'
      rescue => e
        logger.info e
        #if the user is not found then show an error
        #raise ActionController::RoutingError.new('Landing page not found')
        render :file => 'public/404.html', :status => :not_found, :layout => false
      end
    end
  end

  def about
  end

  def contact
  end

  def room
    room = Room.find_by_id params[:room_id]
    if user_signed_in?
      redirect_to(bbb_room_enter_path(room))
    elsif params[:password] == room.moderator_password || params[:password] == room.viewer_password
      bbb_meeting_join_url = bbb_get_meeting_join_url room, params[:username], params[:password]
      if bbb_meeting_join_url[:returncode]
          #Execute the redirect
          logger.info "#Execute the redirect"
          redirect_to bbb_meeting_join_url[:join_url]
        else
          @error = { :key => bbb_meeting_join_url[:messageKey], :message => bbb_meeting_join_url[:message] }
          redirect_to :back
        end
    else
      flash[:error] = "Incorrect Password"
      redirect_to :back
    end
  end
end
