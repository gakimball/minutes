class ArticlesController < ApplicationController
  respond_to :html, :json

  def show
    retriever = ArticlesRetriever.new(API_KEYS["pocket"], pocket_token)

    retriever.archive(params[:current]) if params[:current]

    @article = retriever.find(params[:minutes].to_i, params[:type])
    respond_with @article, status: @article.present? ? :ok : :unprocessable_entity
  end

  private

  def pocket_token
    current_user.services.pocket.token
  end
end
