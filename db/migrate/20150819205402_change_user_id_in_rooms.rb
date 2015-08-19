class ChangeUserIdInRooms < ActiveRecord::Migration
  def change
    change_column :rooms, :user_id, :integer
  end
end
