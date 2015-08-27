class RoomsController < ApplicationController
  include BbbHelper

  #before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :authenticate_user!

  load_and_authorize_resource

  def index
    @user = current_user
    if @user.has_role? :admin
      @rooms = Room.all
    else
      @rooms = Room.where(:user_id => @user.id)
    end
  end

  def show
    @room = Room.find(params[:id])
    if user_signed_in?
      @join_url = root_path+'bbb/join/'+@room.id.to_s
    else
      @join_url = nil
    end
  end

  def new
    @room = Room.new
  end

  def create
    #@room = Room.new(params.require(:room).permit(:name, :description))
    @room = Room.new(room_params) do |r|
      r.user_id = current_user.id
      r.recording = false
    end

    if @room.save
      redirect_to @room
    else
      render 'new'
    end
  end

  def edit
    @room = Room.find(params[:id])
  end

  def update
    @room = Room.find(params[:id])

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
        params.require(:room).permit(:name, :description, :user_id, :recording)
    end

end
