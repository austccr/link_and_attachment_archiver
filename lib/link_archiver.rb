require_relative 'link_archiver/parse_html.rb'
require_relative 'link_archiver/archive_links.rb'

class LinkArchiver
  attr_accessor :links
  attr_accessor :source_url

  def initialize(links: nil, source_url:)
    @links = links || []
    @source_url = source_url
  end

  def parse_html_and_archive_links(string)
    parse_html(string)
    archive_links
  end
end
