class RoomsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  def index
    @rooms = Room.all
  end

  def show
    @room = Room.find(params[:id])
  end

  def new
    @room = Room.new
  end

  def create
    #render plain: room_params.inspect
    #@room = Room.new(params.require(:room).permit(:name, :description))
    @room = Room.new(room_params)

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
        params.require(:room).permit(:name, :description)
    end

end
