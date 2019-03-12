require 'scraperwiki'
require 'typhoeus'
require 'json'
require_relative 'lib/link_archiver'

MORPH_API_KEY = ENV['MORPH_API_KEY']
MORPH_API_URL = 'https://api.morph.io/austccr/mca_media_releases_scraper/data.json'
PER_PAGE = 5

def archive_links_from_morph_results(current_offset, total_links, total_records)
  query = "select * from \"data\" limit #{PER_PAGE} offset #{current_offset}"

  puts "Requesting records #{current_offset + 1} to #{current_offset + PER_PAGE} with '#{query}'"
  response = Typhoeus.get(
    MORPH_API_URL, params: { key: MORPH_API_KEY, query: query }
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

      ScraperWiki.save_sqlite([:url, :source_url], link)

      total_links += 1

      sleep 1
    end

    total_records += 1
  end

  if records_json.count.eql? PER_PAGE
    current_offset += PER_PAGE
    archive_links_from_morph_results(current_offset, total_links, total_records)
  else
    puts "Finished..."
    puts "Archived #{total_links} urls from #{total_records} records."
  end
end

current_offset = 0
total_links = 0
total_records = 0

puts "Searching for records at #{MORPH_API_URL}"
archive_links_from_morph_results(current_offset, total_links, total_records)
