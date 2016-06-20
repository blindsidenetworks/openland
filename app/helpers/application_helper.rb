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

  def is_registration_open?
    if (defined? APP_CONFIG).to_s == 'constant' && (APP_CONFIG.has_key? 'registration_open')
      APP_CONFIG['registration_open']
    else
      false
    end
  end

  def is_signin_enabled?
    if (ENV.has_key? 'OPENLAND_SIGNIN_ENABLED')
      ENV['OPENLAND_SIGNIN_ENABLED'].downcase == 'true'
    else
      false
    end
  end

  def is_signup_enabled?
    if (ENV.has_key? 'OPENLAND_SIGNUP_ENABLED')
      ENV['OPENLAND_SIGNUP_ENABLED'].downcase == 'true'
    else
      false
    end
  end

  def landing_style
    if (ENV.has_key? 'OPENLAND_LANDING_STYLE')
      ENV['OPENLAND_LANDING_STYLE'].downcase
    else
      'classic'
    end
  end

  def bbb_endpoint
    if (defined? APP_CONFIG).to_s == 'constant' && (APP_CONFIG.has_key? 'bbb_endpoint')
      APP_CONFIG['bbb_endpoint']
    else
      'http://test-install.blindsidenetworks.com/bigbluebutton/'
    end
  end

  def bbb_secret
    if (defined? APP_CONFIG).to_s == 'constant' && (APP_CONFIG.has_key? 'bbb_secret')
      APP_CONFIG['bbb_secret']
    else
      '8cd8ef52e8e101574e400365b55e11a6'
    end
  end

  def random_password(length)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    password = (0...length).map { o[rand(o.length)] }.join
    return password
  end
end
