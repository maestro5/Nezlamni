class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private
    def authorized?
      false
    end

    def verify_authorization!
      unless authorized?
        flash[:error] = I18n.t('.flash.access_denied')
        redirect_to root_path
      end
    end
end
