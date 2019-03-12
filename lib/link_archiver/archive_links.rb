class LinkArchiver
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

    request = Typhoeus::Request.new(
      "https://web.archive.org/save/#{url}",
      method: :head
    )

    request.on_complete do |response|
      if response.success?
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
