require_relative 'link_archiver/parse_html.rb'

class LinkArchiver
  attr_accessor :links
  attr_accessor :source_url

  def initialize(source_url:)
    @links = []
    @source_url = source_url
  end

  def archive_links
    links.each_with_index do |link,i|
      links[i] = link.merge!(web_archive(link[:url]))
    end
  end

  private

  def web_archive(url)
    response_details = {
      syndication: nil,
      errors: nil
    }

    archive_request_response = Typhoeus.head("https://web.archive.org/save/#{url}")

    response_details[:syndication] = [
      "https://web.archive.org",
      archive_request_response.headers['content-location']
    ].join

    response_details
  end
end
