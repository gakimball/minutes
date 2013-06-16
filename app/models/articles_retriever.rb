require 'diffbot'

class ArticlesRetriever
  include ActionView::Helpers::TextHelper

  WPM = 200 # Data from wikipedia on average reading speed

  def initialize(client_key, access_token)
    PocketApi.configure(client_key: client_key, access_token: access_token)
  end

  def find(minutes = nil)
    build_article first(minutes).last # [0] is pocket id
  end

  def archive(id)
    PocketApi.modify("archive", item_id: id)
  end

  private

  def first(minutes)
    PocketApi.retrieve(state: "unread", contentType: "article").select{|_, item| minutes.zero? || minutes(item) <= minutes}.sort{|response| minutes(response.last)}.last
  end

  def build_article(pocket_item)
    Article.new(
      id: pocket_item["item_id"],
      url: pocket_item["resolved_url"],
      title: pocket_item["resolved_title"],
      excerpt: pocket_item["resolved_title"],
      minutes: pocket_item["word_count"].to_i / WPM,
      content: simple_format(content(pocket_item["resolved_url"])))
  end

  def minutes(pocket_response)
    pocket_response["word_count"].to_i / WPM
  end

  def content(url)
    diffbot_client = Diffbot.new
    diffbot_client.set_url(url)
    diffbot_client.get_text
  end
end
