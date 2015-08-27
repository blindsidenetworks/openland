require 'role_model'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Roles implemented using role_model

  # 0000 0001 =  1 = [:admin]
  # 0000 0010 =  2 = [:manager]
  # 0000 0100 =  4 = [:member]
  # 0000 1000 =  8 = [:instructor]
  # 0001 0000 = 16 = [:student]
  # 0000 0110 =  6 = [:manager, :member]
  # 0000 0101 =  5 = [:admin, :member]

  # By default, when auto-refistration is allowed all the accounts are created with
  # the role member
  include RoleModel

  # if you want to use a different integer attribute to store the
  # roles in, set it with roles_attribute :my_roles_attribute,
  # :roles_mask is the default name
  roles_attribute :roles_mask

  # declare the valid roles -- do not change the order if you add more
  # roles later, always append them at the end!
  roles :admin, :manager, :member, :instructor, :student


  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  validates :username,
    :presence => true,
    :uniqueness => {
      :case_sensitive => false
    }

  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions.to_hash).first
    end
  end
end
