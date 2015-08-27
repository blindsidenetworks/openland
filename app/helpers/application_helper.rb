module ApplicationHelper
  class String
    def is_numeric?
      Float(self) != nil rescue false
    end
  end

  def is_number? string
    true if Float(string) rescue false
  end

  def get_username(user_id)
    user = User.find_by_id(user_id)
    (user != nil)? user.username: nil
  end
end
