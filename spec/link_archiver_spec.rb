require_relative '../lib/link_archiver'

RSpec.describe LinkArchiver do
  it 'must have a source url' do
    expect { LinkArchiver.new }.to(
      raise_error(ArgumentError, 'missing keyword: source_url')
    )
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
  end
end
