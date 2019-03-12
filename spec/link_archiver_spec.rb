require_relative '../lib/link_archiver'

RSpec.describe LinkArchiver do
  it 'must have a source url' do
    expect { LinkArchiver.new }.to(
      raise_error(ArgumentError, 'missing keyword: source_url')
    )
  end

  describe '#archive_links' do
    let(:archiver) do
      LinkArchiver.new(source_url: 'https://foo.org/bar')
    end

    it 'sends the links to the internet archive' do
      archiver.links = [
        { url: 'https://feministinternet.org/' }
      ]

      VCR.use_cassette('internet_archive', record: :once) do
        archiver.archive_links
      end

      expect(archiver.links).to eq [
        {
          url: 'https://feministinternet.org/',
          syndication: 'https://web.archive.org/web/20190312102044/https://feministinternet.org/',
          errors: nil
        }
      ]
    end

    context 'if there are errors' do
      it 'records them' do
        archiver.links = [
          { url: 'https://minerals.org.au' }
        ]

        VCR.use_cassette('internet_archive', record: :once) do
          archiver.archive_links
        end

        expect(archiver.links).to eq [
          {
            url: 'https://minerals.org.au',
            syndication: nil,
            errors: '502: LiveDocumentNotAvailableException: https://minerals.org.au: live document unavailable: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to req'
          }
        ]
      end
    end
  end
end
