class Room < ActiveRecord::Base
  belongs_to :user
  validates :name, :presence => true, :length => { :minimum => 5 }

  def owner
     user = User.find_by_id(user_id)
     user
  end
end
