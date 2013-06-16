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

