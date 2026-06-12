class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!, only: [:new, :create]
  layout -> { action_name == "new" ? false : "application" }
end
