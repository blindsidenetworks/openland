class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.id != nil
      can :read, Room
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
      can [:update, :destroy], Room, :user_id => user.id
    end

  end
end
