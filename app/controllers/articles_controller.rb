class ArticlesController < ApplicationController
  before_action :require_user

  respond_to :html, :json

  def show
    retriever = ArticlesRetriever.new(API_KEYS["pocket"], params[:token] || session[:oauth_token])

    retriever.archive(params[:current]) if params[:current]

    @article = retriever.find(params[:minutes].to_i, params[:type])
    respond_with @article, status: @article.present? ? :ok : :unprocessable_entity
  end
end
