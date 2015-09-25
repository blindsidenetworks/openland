module UsersHelper
  def role_name(role_key)
    t('users.'+role_key)
  end
end
