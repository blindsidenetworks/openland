class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  def digitalocean
      @user = User.from_omniauth(request.env["omniauth.auth"])
      sign_in_and_redirect @user
  end

  def twitter
      @user = User.from_omniauth(request.env["omniauth.auth"])
      sign_in_and_redirect @user
  end

  def facebook
      @user = User.from_omniauth(request.env["omniauth.auth"])
      sign_in_and_redirect @user
  end

  def google_oauth2
      @user = User.from_omniauth(request.env["omniauth.auth"])
      sign_in_and_redirect @user
  end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
