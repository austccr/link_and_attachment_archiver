require_relative '../lib/link_archiver'

RSpec.describe LinkArchiver do
  it 'must have a source url' do
    expect { LinkArchiver.new }.to(
      raise_error(ArgumentError, 'missing keyword: source_url')
    )
  end

  it 'can be initialized without links' do
    archiver = LinkArchiver.new(source_url: 'http://foo.net')

    expect(archiver.links).to match []
  end

  it 'can be initialized with links' do
    archiver = LinkArchiver.new(
      source_url: 'http://foo.net',
      links: [ { url: 'http://bar.org' } ]
    )

    expect(archiver.links).to match [ { url: 'http://bar.org' } ]
  end

  describe '#parse_html_and_archive_links' do
    context 'example.html' do
      let(:html) { File.read('./spec/fixtures/example.html') }

      it 'pings archive.or for all the present links' do
        archiver = LinkArchiver.new(
          source_url: 'http://minerals.org.au/news/peru-australia-free-trade-agreement-will-deliver-investment-and-jobs-australia'
        )

        VCR.use_cassette('internet_archive', record: :once) do
          archiver.parse_html_and_archive_links(html)
        end

        expect(archiver.links).to eq [
          {
            errors: nil,
            syndication: 'https://web.archive.org/web/20190312113619/http://minerals.org.au/files/190226-peru-australia-free-trade-agreement-will-deliver-investment-and-jobs-australiapdf',
            url: 'http://minerals.org.au/files/190226-peru-australia-free-trade-agreement-will-deliver-investment-and-jobs-australiapdf'
          },
          {
            errors: '502: LiveDocumentNotAvailableException: https://minerals.org.au/sites/default/files/190226%20Peru-Australia%20Free%20Trade%20Agreement%20will%20deliver%20investment%20and%20jobs%20for%20Australia.pdf: live document unavailable: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorExceptio',
            syndication: nil,
            url: 'https://minerals.org.au/sites/default/files/190226%20Peru-Australia%20Free%20Trade%20Agreement%20will%20deliver%20investment%20and%20jobs%20for%20Australia.pdf'
          }
        ]
      end
    end

    context 'example_09.html' do
      let(:html) { File.read('./spec/fixtures/example_09.html') }

      it 'pings archive.or for all the present links' do
        archiver = LinkArchiver.new(
          source_url: 'http://minerals.org.au/new_report_backs_carbon_capture_and_storage_in_australia'
        )

        VCR.use_cassette('internet_archive', record: :once) do
          archiver.parse_html_and_archive_links(html)
        end

        expect(archiver.links).to eq [
          {
            errors: nil,
            syndication: 'https://web.archive.org/web/20190312114818/http://www.minerals.org.au/file_upload/files/publications/UQE003_CCS_report_HR.PDF',
            url: 'http://www.minerals.org.au/file_upload/files/publications/UQE003_CCS_report_HR.PDF'
          },
          {
            errors: '404: ',
            syndication: nil,
            url: 'http://minerals.org.au/UQE003_CCS_report_HR.PDF'
          },
          {
            errors: '404: ',
            syndication: nil,
            url: 'http://minerals.org.au/WP1_Energy_and_Climate.pdf'
          },
          {
            errors: nil,
            syndication: 'https://web.archive.org/web/20190312114821/http://www.minerals.org.au/file_upload/files/publications/WP1_Energy_and_Climate.pdf',
            url: 'http://www.minerals.org.au/file_upload/files/publications/WP1_Energy_and_Climate.pdf'
          },
          {
            errors: nil,
            syndication: 'https://web.archive.org/web/20190312114822/http://www.minerals.org.au/file_upload/files/publications/WP2_Financial_Incentives.pdf',
            url: 'http://www.minerals.org.au/file_upload/files/publications/WP2_Financial_Incentives.pdf'
          },
          {
            errors: nil,
            syndication: 'https://web.archive.org/web/20190312114823/http://www.minerals.org.au/file_upload/files/publications/WP3_CCS_Roadmaps_and_Projects.pdf',
            url: 'http://www.minerals.org.au/file_upload/files/publications/WP3_CCS_Roadmaps_and_Projects.pdf'
          }
        ]
      end
    end
  end
end
