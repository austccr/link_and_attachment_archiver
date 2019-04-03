class LinkArchiver
  def archive_links(skipped_saved: false)
    links.each_with_index do |link,i|
      if skipped_saved
        existing_link = ScraperWiki.select(
          "* FROM data WHERE url='#{link[:url]}' AND source_url='#{source_url}'"
        ).last rescue nil
      end

      if skipped_saved && existing_link && existing_link["syndication"]
        puts "Skipping #{link[:url]}, which is already archived at #{existing_link['syndication']}"
      else
        puts "Pinging archive.org with #{link[:url]}" if skipped_saved
        links[i] = link.merge!(web_archive(link[:url]))
      end
    end
  end

  private

  def web_archive(url)
    response_details = {
      syndication: nil,
      errors: nil
    }

    request = Typhoeus::Request.new(
      "https://web.archive.org/save/#{url}",
      method: :head
    )

    request.on_complete do |response|
      # When archive.org returns 301, it has still archived the page
      if response.success? || response.code.eql?(301)
        response_details[:syndication] = [
          "https://web.archive.org",
          response.headers['content-location']
        ].join
      else
        response_details[:errors] = [
          response.code.to_s + ': ',
          response.status_message,
          response.headers.dig('x-archive-wayback-runtime-error') || response.headers.dig('X-Archive-Wayback-Runtime-Error')
        ].join
      end
    end

    request.run

    response_details
  end
end
