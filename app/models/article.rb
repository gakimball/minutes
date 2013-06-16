class Article
  include ActiveModel::Model

  attr_accessor :id, :url, :title, :excerpt, :minutes, :content
end
