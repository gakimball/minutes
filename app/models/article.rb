class Article
  include ActiveModel::Model

  attr_accessor :id, :url, :title, :excerpt, :minutes, :content, :parser

  def minutes
    @minutes ||= parser.minutes
  end

  def content
    @content ||= parser.content
  end
end
