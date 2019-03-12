require 'nokogiri'

class LinkArchiver
  attr_reader :links
  attr_accessor :source_url

  def initialize
    @links = []
    @source_url = nil
  end

  def parse_html(string)
    Nokogiri::HTML(string).search(:a).each do |a|
      links << {
        url: a[:href]
      }
    end
  end
end
