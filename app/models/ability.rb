class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    #anyone can read and use
    can :read, Room
    can :use, Room
    if user.has_role? :admin
      can :manage, :all
    else
      can :manage, User do |u|
        u.id == user.id
      end
    end
    if user.has_role? :manager
      can :manage, Room
    end
    if user.has_role? :member
      can [:create], Room
      can [:manage], Room do |r|
        r.user_id == user.id
      end
    end
  end
end
