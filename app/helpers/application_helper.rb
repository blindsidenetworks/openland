module ApplicationHelper
  class String
    def is_numeric?
      Float(self) != nil rescue false
    end
  end

  def is_number? string
    true if Float(string) rescue false
  end
end
