require_relative 'link_archiver/parse_html.rb'

class LinkArchiver
  attr_accessor :links
  attr_accessor :source_url

  def initialize(source_url:)
    @links = []
    @source_url = source_url
  end
end
