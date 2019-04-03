require 'scraperwiki'
require_relative 'link_archiver/parse_html.rb'
require_relative 'link_archiver/archive_links.rb'

class LinkArchiver
  attr_accessor :links
  attr_accessor :source_url

  def initialize(links: nil, source_url:)
    @links = links || []
    @source_url = source_url
  end

  def parse_html_and_archive_links(string, skipped_saved)
    parse_html(string)
    archive_links(skipped_saved: skipped_saved)
  end

  def save_links_to_sqlite
    links.each do |link|
      link.merge!(
        source_url: source_url,
        archived_at: Time.now.utc.to_s
      )

      ScraperWiki.save_sqlite([:url, :source_url], link)
      sleep 1
    end
  end
end
