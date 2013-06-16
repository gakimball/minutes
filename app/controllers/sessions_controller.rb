class SessionsController < ApplicationController
  def new
    redirect_to "/auth/pocket"
  end

  def destroy
    logout!
    redirect_to root_url
  end
end
