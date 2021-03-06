require 'scraperwiki'
require 'typhoeus'
require 'json'
require_relative 'lib/link_archiver'

MORPH_API_KEY = ENV['MORPH_API_KEY']
LW_KEY = ENV['MORPH_LW_KEY']

FEED_URLS = [
  'https://api.morph.io/austccr/bca_media_releases_scraper/data.json',
  'https://lobby-watch.herokuapp.com/api/v0/items.json',
  'https://api.morph.io/austccr/mca_media_releases_scraper/data.json'
]

def save_links(archiver)
  archiver.save_links_to_sqlite
end

def archive_links_from_morph_results(feed_url, current_offset)
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

    archiver.parse_html_and_archive_links(record["content"], true)

    save_links(archiver)
  end

  if records_json.count.eql? per_page
    current_offset += per_page
    archive_links_from_morph_results(feed_url, current_offset)
  else
    puts "Finished #{feed_url}"
  end
end

def archive_links_from_lobbywatch_results(feed_url, current_page)
  per_page = 20
  puts "Requesting items from page #{current_page}"

  response = JSON.parse(
    Typhoeus.get(
      feed_url, params: { key: LW_KEY, page: current_page }
    ).body
  )

  response.each do |record|
    next if record["document"]["url"].nil? || record["document"]["url"].empty?
    archiver = LinkArchiver.new(
      source_url: record["document"]["url"],
      links: [{ url: record["document"]["url"] }]
    )

    archiver.archive_links(skipped_saved: true)

    save_links(archiver)
  end

  if response.count.eql? per_page
    current_page += 1

    archive_links_from_lobbywatch_results(feed_url, current_page)
  else
    puts "Finished #{feed_url}"
  end
end

def work_through_morph_results(feed_url)
  current_offset = 0

  archive_links_from_morph_results(feed_url, current_offset)
end

def work_through_lobbywatch_items(feed_url)
  current_page = 1

  archive_links_from_lobbywatch_results(feed_url, current_page)
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
