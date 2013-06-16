class ArticlesController < ApplicationController
  before_action :require_user

  respond_to :html, :json

  def show
    retriever = ArticlesRetriever.new(API_KEYS["pocket"], session[:oauth_token])

    retriever.archive(params[:current]) if params[:current]

    @article = retriever.find(params[:minutes].to_i)
    respond_with @article
  end
end
