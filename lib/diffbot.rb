require 'net/http'
require 'json'

class Diffbot
  @@uri = URI("http://www.diffbot.com/api/article")
  @@params = { token: API_KEYS["diffbot"] }
  
  def set_url(content_url)
    @@params[:url] = content_url;
    @@params[:tags] = true;
    @data = nil
  end

  def download
    @@uri.query = URI.encode_www_form(@@params)
    response = Net::HTTP.get_response(@@uri)
    @data = JSON.parse(response.body)
  end

  def validate_data
    if @data.nil?
      if @@params[:url].nil?
        puts "ERROR :: Content Url not set"
      end

      download
    end
  end

  def get_text
    validate_data
    @data["text"]
  end

  def get_title
    validate_data
    @data["title"]
  end

  def get_tags
    validate_data
    @data["tags"]
  end

  def get_author
    validate_data
    @data["author"]
  end
end
