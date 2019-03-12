require_relative 'link_archiver/parse_html.rb'
require_relative 'link_archiver/archive_links.rb'

class LinkArchiver
  attr_accessor :links
  attr_accessor :source_url

  def initialize(source_url:)
    @links = []
    @source_url = source_url
  end
end
