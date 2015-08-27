class Room < ActiveRecord::Base
  belongs_to :user
  validates :name, :presence => true, :length => { :minimum => 5 }
end
