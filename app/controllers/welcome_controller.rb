class WelcomeController < ApplicationController
  include ApplicationHelper
  include BbbHelper

  def index
  end

  def landing_traditional
    if is_number?(params[:landing_id])
      @user = User.find_by!(id: params[:landing_id])
    else
      @user = User.find_by!(username: params[:landing_id])
    end
    #If the user is found then look for the room
    @rooms = Room.where(:user_id => @user.id)
    render :layout => 'traditional'
  end

  def open_room
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

  def landing
    logger.info params.inspect
    if params[:landing_id] == 'dashboard' || params[:landing_id] == 'rooms'
      redirect_to '/' + params[:landing_id] + '/index'
    else if params[:landing_id] == 'landing'
      if is_number?(params[:room_id])
        @room = Room.find_by_id params[:room_id]
        if @room == nil
          redirect_to root_url, :alert => 'The room number could not be found'

        else
          if can? :read, @room
            # Prepare URLs
            if can? :use, @room
              @bbb_room_enter_url = bbb_room_enter_path(@room)
            else
              @bbb_room_enter_url = nil
            end
            @bbb_room_status_url = bbb_room_status_path(@room)
            # Retrieve and set @recordings
            bbb_recordings = bbb_get_recordings @room
            if bbb_recordings && bbb_recordings[:returncode] && bbb_recordings[:recordings].any?
              @recordings = bbb_recordings[:recordings]
            else
              @recordings = []
            end
            # Render the room
            render 'landing_room'
          else
            user = User.find(@room.user_id)
            redirect_to root_url+user.username, :alert => 'You don\'t have permissions for seeing this room'
          end
        end

      else
        redirect_to root_url
      end

    else
      begin
        if is_number?(params[:landing_id])
          @user = User.find_by!(id: params[:landing_id])
        else
          @user = User.find_by!(username: params[:landing_id])
        end
        #If the user is found then look for the room
        @rooms = Room.where(:user_id => @user.id)
      rescue
        logger.info "Landing page not found"
        #if the user is not found then show an error
        #raise ActionController::RoutingError.new('Landing page not found')
        render :file => 'public/404.html', :status => :not_found, :layout => false
      end
    end end
  end

  def about
  end

  def contact
  end

end
