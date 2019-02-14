class ApplicationController < ActionController::Base
  include SessionsHelper
  protect_from_forgery with: :exception
  before_action :set_locale

  private

  def set_locale
    locale = params[:locale].to_s.strip.to_sym
    I18n.locale = if I18n.available_locales.include? locale
                    locale
                  else
                    I18n.default_locale
                  end
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def logged_in_user
    return false if logged_in?
    store_location
    flash[:danger] = t "ple_login"
    redirect_to login_url
  end
end
