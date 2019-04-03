require 'scraperwiki'
require 'typhoeus'
require 'json'
require_relative 'lib/link_archiver'

MORPH_API_KEY = ENV['MORPH_API_KEY']
MORPH_API_URL = 'https://api.morph.io/austccr/mca_media_releases_scraper/data.json'

FEED_URLS = [
  'https://lobby-watch.herokuapp.com/api/v0/items.json',
  MORPH_API_URL
]

def save_links(archiver, totals_counter)
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

    sleep 1

    totals_counter += 1
  end

  totals_counter
end

def archive_links_from_morph_results(feed_url, current_offset, total_links, total_records)
  per_page = 5

  query = "select * from \"data\" limit #{per_page} offset #{current_offset}"

  puts "Requesting records #{current_offset + 1} to #{current_offset + per_page} with '#{query}'"
  response = Typhoeus.get(
    feed_url, params: { key: MORPH_API_KEY, query: query }
  )

  records_json = JSON.parse(response.response_body)
  records_json.each do |record|
    puts "Extracting and archiving links from #{record["url"]}"
    archiver = LinkArchiver.new(source_url: record["url"])

    archiver.parse_html_and_archive_links(record["content"])

    total_links = save_links(archiver, total_links)

    total_records += 1
  end

  if records_json.count.eql? per_page
    current_offset += per_page
    archive_links_from_morph_results(feed_url, current_offset, total_links, total_records)
  else
    puts "Finished #{feed_url}"
    puts "Archived #{total_links} URLs from #{total_records} records."
  end
end

def archive_links_from_lobbywatch_results(feed_url, current_offset, total_links, total_records)
  per_page = 20
  puts "Requesting items #{current_offset + 1} to #{current_offset + per_page}"

  response = JSON.parse(
    Typhoeus.get(
      feed_url, params: { offset: current_offset }
    ).body
  )

  response.each do |record|
    puts "Archiving #{record["url"]}"
    archiver = LinkArchiver.new(
      source_url: record["url"],
      links: [{ url: record["url"] }]
    )

    archiver.archive_links

    total_records += save_links(archiver, total_records)
  end

  if response.count.eql? per_page
    current_offset += per_page

    archive_links_from_lobbywatch_results(
      feed_url, current_offset, total_links, total_records
    )
  else
    puts "Finished #{feed_url}"
    puts "Archived #{total_records} URLs."
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

def work_through_lobbywatch_items(feed_url)
  current_offset = 0
  total_links = 0
  total_records = 0

  archive_links_from_lobbywatch_results(
    feed_url, current_offset, total_links, total_records
  )
end

FEED_URLS.each do |feed_url|
  puts "Searching for records at #{feed_url}"

  case
  when feed_url.start_with?('https://api.morph.io')
    work_through_morph_results(feed_url)
  when feed_url.eql?('https://lobby-watch.herokuapp.com/api/v0/items.json')
    work_through_lobbywatch_items(feed_url)
  else
    puts 'Sorry, we dont know how to parse this feed'
  end
  puts
  puts
end
