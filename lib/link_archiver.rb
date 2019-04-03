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

  def parse_html_and_archive_links(string)
    parse_html(string)
    archive_links
  end

  def save_links_to_sqlite
    links.each do |link|
      link.merge!(
        source_url: source_url,
        archived_at: Time.now.utc.to_s
      )

      # TODO: Attempt to re-archive and update the link if there are errors on the existing record
      #
      # This should probably be extracted into lib so that it can be done without pining archive.org redundantly
      #
      # Get the existing record with something like
      # existing_link = ScraperWiki.select(
      #   "* FROM data WHERE url='#{link[:url]}' AND source_url='#{link[:source_url]}'"
      # ).last rescue nil

      ScraperWiki.save_sqlite([:url, :source_url], link)
      sleep 1
    end
  end
end
