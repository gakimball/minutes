class VimeoParser
  def initialize(vimeo_id)
    @vimeo_id = vimeo_id
  end

  def minutes
    @minutes ||= info["duration"] / 60
  end

  def content
    @content ||= embed_info["html"]
  end

  private

  def embed_info
    HTTParty.get(embed_info_uri)
  end

  def embed_info_uri
    "http://api.embed.ly/1/oembed?key=#{API_KEYS["embedly"]}&url=http://vimeo.com/#{@vimeo_id}"
  end

  def info
    response = HTTParty.get(info_uri)
    if response.code > 400
      { "duration" => 0 }
    else
      response.first
    end
  end

  def info_uri
    "http://vimeo.com/api/v2/video/#{@vimeo_id}.json"
  end
end

