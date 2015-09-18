module ApplicationHelper
  class String
    def is_numeric?
      Float(self) != nil rescue false
    end
  end

  def is_number? string
    true if Float(string) rescue false
  end

  def controller_namex(controller_param)
    if controller_param != nil
      controller_namex = controller_param.split('/', 2).first
    else
      controller_namex = ''
    end
    controller_namex
  end
end
