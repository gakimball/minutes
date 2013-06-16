class ServicesController < ApplicationController
  def new; end

  def create
    current_service = Service.where(provider: omnihash[:provider], uid: omnihash[:uid]).first

    if logged_in?
      if current_service
        flash[:notice] = I18n.t('notifications.provider_already_connected', provider: omnihash[:provider].capitalize)
      else
        current_user.services.create!({
          provider: omnihash[:provider],
          uid: omnihash[:uid]
        })

        flash[:notice] = I18n.t('notifications.provider_added', provider: omnihash[:provider].capitalize)
      end
    else
      if current_service
        session[:user_id]            = current_service.user.id
        session[:service_id]         = current_service.id
        session[:oauth_token]        = omnihash[:credentials][:token]
        session[:oauth_token_secret] = omnihash[:credentials][:secret]
      else
        user         = User.new
        user.name    = omnihash[:info][:nickname]
        user.email   = omnihash[:info][:email]
        user_service = user.services.build({
          provider: omnihash[:provider],
          uid: omnihash[:uid]
        })

        if user.save!
          session[:user_id]            = user.id
          session[:service_id]         = user_service.id
          session[:oauth_token]        = omnihash[:credentials][:token]
          session[:oauth_token_secret] = omnihash[:credentials][:secret]

          flash[:notice] = I18n.t('notifications.account_created')
        end
      end
    end

    redirect_to root_path
  end

  def token
    render json: { request_token: ArticlesRetriever.new(API_KEYS["pocket"]).request_token(params[:uri]) }
  end

  def destroy
    service = current_user.services.find(params[:id])
    if service.respond_to?(:destroy) and service.destroy
      flash[:notice] = I18n.t('notifications.provider_unlinked', provider: service.provider.capitalize)
      redirect_to services_path
    end
  end

  def failure
    flash[:error] = I18n.t('notifications.authentication_error')
    redirect_to root_url
  end

  private

  def omnihash
    request.env['omniauth.auth']
  end
end
