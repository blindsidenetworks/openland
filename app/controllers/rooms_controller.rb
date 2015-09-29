class RoomsController < ApplicationController
  include ApplicationHelper
  include BbbHelper
  #before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @user = current_user
    if (@user.has_role? :admin) || (@user.has_role? :manager)
      @rooms = Room.all
    else
      @rooms = Room.where(:user_id => @user.id)
    end
  end

  def show
    bbb_recordings = bbb_get_recordings @room
    if bbb_recordings[:returncode] && bbb_recordings[:recordings].any?
       @recordings = bbb_recordings[:recordings]
    else
       @recordings = []
    end
  end

  def new
  end

  def create
    @room = Room.new(room_params) do |r|
      r.user_id = current_user.id

      room_params['moderator_password'].strip
      if room_params['moderator_password'].blank?
        r.moderator_password = random_password(8)
      end
      room_params['viewer_password'].strip
      if room_params['viewer_password'].blank?
        begin
          r.viewer_password = random_password(8)
        end while r.moderator_password == r.viewer_password
      end
    end

    if @room.save
      redirect_to @room
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    params[:room][:moderator_password].strip
    if params[:room][:moderator_password].blank?
      params[:room][:moderator_password] = random_password(8)
    end
    params[:room][:viewer_password].strip
    if params[:room][:viewer_password].blank?
      begin
        params[:room][:viewer_password] = random_password(8)
      end while params[:room][:moderator_password] == params[:room][:viewer_password]
    end

    if @room.update(room_params)
      redirect_to @room
    else
      render 'edit'
    end
  end

  def destroy
    @room = Room.find(params[:id])
    @room.destroy
    redirect_to rooms_path
  end

  private
    def room_params
        params.require(:room).permit(:name, :description, :welcome, :moderator_password, :viewer_password, :wait_moderator, :recording, :user_id, :permissions)
    end

end
