require 'diffbot'

class PocketApi::Connection
  def self.generate_access_data
    response = post("/v3/oauth/authorize", {:body => MultiJson.dump({:code => @request_token, :consumer_key => @client_key}), :headers => {"Content-Type" => "application/json; charset=UTF-8", "X-Accept" => "application/json"}})
    response.parsed_response
  end
end

class ArticlesRetriever
  BLACKLISTED = /slideshare\.net/

  def initialize(client_key, access_token = nil)
    @client_key = client_key
    PocketApi.configure(client_key: client_key, access_token: access_token)
  end

  def find(minutes = nil, type = "all")
    biggest_under(minutes, type).tap {|article| article.content if article} # so the json returns the content
  end

  def archive(id)
    PocketApi.modify("archive", item_id: id)
  end

  def request_token(uri)
    PocketApi::Connection.generate_request_token consumer_key: @client_key, redirect_uri: uri
  end

  def access_data(request_token)
    PocketApi::Connection.client_key = @client_key
    PocketApi::Connection.request_token = request_token

    PocketApi::Connection.generate_access_data
  end

  private

  def biggest_under(minutes, type)
    PocketApi.retrieve(state: "unread", detailType: "simple", contentType: type).
      reject {|_id, item| parser_for(item).nil? }.
      map {|item| build_article(item.last)}.
      reject {|article| minutes > 0 && article.minutes > minutes}.
      reject {|article| blacklisted?(article.url)}.
      sort_by(&:minutes).
      last
  end

  def build_article(pocket_item)
    parser = parser_for(pocket_item)

    Article.new(
      id: pocket_item["item_id"],
      url: pocket_item["resolved_url"],
      title: pocket_item["resolved_title"],
      excerpt: pocket_item["resolved_title"],
      parser: parser)
  end

  def parser_for(pocket_item)
    return nil unless pocket_item["is_article"].to_i == 1 or pocket_item["has_video"].to_i == 2

    case pocket_item["has_video"].to_i
    when 0 then TextParser.new(url: pocket_item["resolved_url"], words: pocket_item["word_count"].to_i)
    when 2 then video_parser(pocket_item["resolved_url"])
    end
  end

  def video_parser(url)
    if url =~ /vimeo.com\/(\d*)/
      VimeoParser.new($1)
    end
  end

  def blacklisted?(url)
    url =~ BLACKLISTED
  end
end
