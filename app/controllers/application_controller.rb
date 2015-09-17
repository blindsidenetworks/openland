##########################################################################################
#                                                                                        #
#    OpenLand is a web application that allows creation of landing pages                 #
#    for managing access to BigBlueButton Meeting Rooms.                                 #
#                                                                                        #
#    Copyright (c) 2015 Blindside Networks Inc. and by respective authors (see below).   #
#                                                                                        #
#    This program is free software: you can redistribute it and/or modify                #
#    it under the terms of the GNU General Public License as published by                #
#    the Free Software Foundation, either version 3 of the License, or                   #
#    (at your option) any later version.                                                 #
#                                                                                        #
#    This program is distributed in the hope that it will be useful,                     #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of                      #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                       #
#    GNU General Public License for more details.                                        #
#                                                                                        #
#    You should have received a copy of the GNU General Public License                   #
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.               #
#                                                                                        #
# -------------------------------------------------------------------------------------- #
#    Authors:                                                                            #
#       Jesus Federico, jesus at blindsidenetworks dot com                               #
#       ...                                                                              #
#                                                                                        #
##########################################################################################

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  layout :layout_by_resource

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      redirect_to dashboard_url, :alert => exception.message
    else
      redirect_to root_url, :alert => exception.message
    end
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :first_name, :last_name) }
  end

  def layout_by_resource
    if devise_controller?
      if resource_name == :user && controller_name == "registrations" && action_name == "edit"
         "application"
      else
         "devise"
      end
    end
  end
end
