class AddRecordingToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :recording, :boolean
  end
end
