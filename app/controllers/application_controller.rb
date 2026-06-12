class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_locale
  before_action :authenticate_user!

  protected

  def set_locale
    requested = cookies[:locale]&.to_sym
    I18n.locale = I18n.available_locales.include?(requested) ? requested : :uk
  end

  def after_sign_in_path_for(resource)
    root_path
  end
end
