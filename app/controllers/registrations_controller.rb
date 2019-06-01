class RegistrationsController < Devise::RegistrationsController
  before_action :at_least_one_user_registered, only: %i[new create]
  after_action :remove_message, only: [:update]

  private

  def at_least_one_user_registered
    redirect_to root_path if User.count.positive?
  end

  def remove_message
    session[:display_password_change] = false
    flash.discard(:alert)
  end
end