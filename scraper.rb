require 'scraperwiki'
require 'typhoeus'
require 'json'
require_relative 'lib/link_archiver'

MORPH_API_KEY = ENV['MORPH_API_KEY']
MORPH_API_URL = 'https://api.morph.io/austccr/mca_media_releases_scraper/data.json'
PER_PAGE = 5

FEED_URLS = [
  'https://lobby-watch.herokuapp.com/api/v0/items.json',
  MORPH_API_URL
]

def archive_links_from_morph_results(feed_url, current_offset, total_links, total_records)
  query = "select * from \"data\" limit #{PER_PAGE} offset #{current_offset}"

  puts "Requesting records #{current_offset + 1} to #{current_offset + PER_PAGE} with '#{query}'"
  response = Typhoeus.get(
    feed_url, params: { key: MORPH_API_KEY, query: query }
  )

  records_json = JSON.parse(response.response_body)
  records_json.each do |record|
    puts "Extracting and archiving links from #{record["url"]}"
    archiver = LinkArchiver.new(source_url: record["url"])

    archiver.parse_html_and_archive_links(record["content"])

    archiver.links.each do |link|
      link.merge!(
        source_url: archiver.source_url,
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

      total_links += 1

      sleep 1
    end

    total_records += 1
  end

  if records_json.count.eql? PER_PAGE
    current_offset += PER_PAGE
    archive_links_from_morph_results(feed_url, current_offset, total_links, total_records)
  else
    puts "Finished..."
    puts "Archived #{total_links} urls from #{total_records} records."
  end
end

def work_through_morph_results(feed_url)
  current_offset = 0
  total_links = 0
  total_records = 0

  archive_links_from_morph_results(
    feed_url, current_offset, total_links, total_records
  )
end

FEED_URLS.each do |feed_url|
  puts "Searching for records at #{feed_url}"

  case
  when feed_url.start_with?('https://api.morph.io')
    work_through_morph_results(feed_url)
  when feed_url.eql?('https://lobby-watch.herokuapp.com/api/v0/items.json')
    puts 'Sorry, we dont know how to parse Lobbywatch yet'
  else
    puts 'Sorry, we dont know how to parse this feed'
  end
end