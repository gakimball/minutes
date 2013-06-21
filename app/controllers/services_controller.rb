class ServicesController < ApplicationController
  def create
    current_service = Service.where(provider: omnihash[:provider], uid: omnihash[:uid]).first
    token = SecureRandom.hex(24)

    if current_service
      current_service.user.update_attribute :token, token
      current_service.update_attribute :token, omnihash[:credentials][:token]
    else
      user = User.new(
        name: omnihash[:info][:nickname],
        email: omnihash[:info][:email],
        token: token)

      user.services.build(
        provider: omnihash[:provider],
        uid: omnihash[:uid],
        token: omnihash[:credentials][:token])

      user.save!
    end

    redirect_to auth_success_url(token: token)
  end

  def success
    render :close_window
  end

  def failure
    render :close_window
  end

  private

  def omnihash
    request.env['omniauth.auth']
  end
end
