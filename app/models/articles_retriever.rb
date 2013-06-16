require 'diffbot'

class PocketApi::Connection
  def self.generate_access_data
    response = post("/v3/oauth/authorize", {:body => MultiJson.dump({:code => @request_token, :consumer_key => @client_key}), :headers => {"Content-Type" => "application/json; charset=UTF-8", "X-Accept" => "application/json"}})
    response.parsed_response
  end
end

class TextParser
  WPM = 200 # Data from wikipedia on average reading speed

  def initialize(params)
    @url = params[:url]
    @words = params[:words]
  end

  def minutes
    @words / WPM
  end

  def content
    diffbot_client = Diffbot.new
    diffbot_client.set_url(@url)
    format_html diffbot_client.get_text
  end

  def format_html(text)
    "<p>" + text.gsub(/\n/, "</p>\n<p>") + "</p>"
  end
end

class VimeoParser
  def initialize(vimeo_id)
    @vimeo_id = vimeo_id
  end

  def minutes
    info["duration"] / 60
  end

  def content
    embed_info["html"]
  end

  private

  def embed_info
    HTTParty.get(embed_info_uri)
  end

  def embed_info_uri
    "http://api.embed.ly/1/oembed?url=http://vimeo.com/#{@vimeo_id}"
  end

  def info
    HTTParty.get(info_uri).first
  end

  def info_uri
    "http://vimeo.com/api/v2/video/#{@vimeo_id}.json"
  end
end

class ArticlesRetriever
  def initialize(client_key, access_token = nil)
    @client_key = client_key
    PocketApi.configure(client_key: client_key, access_token: access_token)
  end

  def find(minutes = nil)
    biggest_under(minutes).tap {|article| article.content} # so the json returns the content
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

  def biggest_under(minutes)
    PocketApi.retrieve(state: "unread", detailType: "simple").
      reject {|_id, item| parser_for(item).nil? }.
      map {|item| build_article(item.last)}.
      reject {|article| minutes > 0 && article.minutes > minutes}.
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
end
