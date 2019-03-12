require 'nokogiri'

class LinkArchiver
  def parse_html(string)
    extracted_links = []

    Nokogiri::HTML(string).search(:a).each do |a|
      url = URI.parse(a[:href])

      if url.is_a? URI::Generic
        url = URI.join(source_url, url)
      end

      extracted_links << { url: url.to_s }
    end

    self.links += extracted_links.uniq
  end
end
