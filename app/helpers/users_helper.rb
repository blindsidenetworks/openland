module UsersHelper
  def role_name(role_key)
    role_key.capitalize
  end

  def roles
    roles = []
    valid_roles = User.valid_roles
    valid_roles.each do |valid_role|
      role = [role_name(valid_role), valid_role]
      roles << role
    end
    roles
  end
end
