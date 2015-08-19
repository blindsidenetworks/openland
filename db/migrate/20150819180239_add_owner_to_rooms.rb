class AddOwnerToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :user_id, :string
  end
end
