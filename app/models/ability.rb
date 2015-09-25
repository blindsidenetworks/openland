class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    #anyone can read and use
    can :read, Room
    can :use, Room
    if user.id != nil
      can :use, Room
      #can [:update, :destroy], User, :id => user.id
    end
    if user.has_role? :admin
      can :manage, :all
    end
    if user.has_role? :manager
      can :manage, Room
    end
    if user.has_role? :member
      can [:create], Room
      can [:update, :destroy, :close], Room, :user_id => user.id
      can :manage, User do |u|
        user.id == u.id
      end
    end
  end
end
