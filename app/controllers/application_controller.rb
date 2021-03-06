class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from Pundit::NotDefinedError, with: :user_not_authorized

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:email, :password, :password_confirmation, :first_name,
                 :last_name, :pesel, :phone_number,
                 address_attributes: [ :street, :house_number, :flat_number,
                                       :city, :borough, :district, :province,
                                       :country, :zip_code, :user_id ])
      end
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(:email, :password, :password_confirmation, :current_password,
                 :first_name, :last_name, :pesel, :phone_number,
                 address_attributes: [ :street, :house_number, :flat_number,
                                       :city, :borough, :district, :province,
                                       :country, :zip_code, :user_id ])
      end
    end

  def authenticate_veterinarian!
    if current_user.nil?
      authenticate_user!
    elsif !current_user.weterynarz?
      render file: File.join(Rails.root, 'public/403.html'), status: 403, layout: false
    end
  end

  def change_comma_to_period(number_string)
    number_string.gsub(',', '.').to_f unless number_string.nil?
  end

  private

    def user_not_authorized
      render file: File.join(Rails.root, 'public/403.html'), status: 403, layout: false
    end
end
