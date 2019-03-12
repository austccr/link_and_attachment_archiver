require 'nokogiri'

class LinkArchiver
  attr_accessor :links
  attr_accessor :source_url

  def initialize(source_url:)
    @links = []
    @source_url = source_url
  end

  def parse_html(string)
    extracted_links = []

    Nokogiri::HTML(string).search(:a).each do |a|
      url = URI.parse(a[:href])

      if url.is_a? URI::Generic
        url = URI.join(source_url, url)
      end

      extracted_links << { url: url.to_s }
    end

    self.links += extracted_links
  end
end
