class AddPermissionsToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :welcome, :string
    add_column :rooms, :moderator_password, :string
    add_column :rooms, :viewer_password, :string
    add_column :rooms, :wait_moderator, :boolean
    add_column :rooms, :permissions, :string
  end
end
