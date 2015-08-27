class Ability
  include CanCan::Ability

  def initialize(user)
    #All users (including guests)
    can :read, Room

    user ||= User.new
    if user.id != nil
      can :manage, :all
    end
  end
end
