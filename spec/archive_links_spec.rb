require_relative '../lib/link_archiver'

RSpec.describe LinkArchiver do
  describe '#archive_links' do
    around do |example|
      VCR.use_cassette('internet_archive', record: :once) do
        example.run
      end
    end

    let(:archiver) do
      LinkArchiver.new(source_url: 'https://foo.org/bar')
    end

    it 'sends the links to the internet archive' do
      archiver.links = [
        { url: 'https://feministinternet.org/' }
      ]

      archiver.archive_links

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

        archiver.archive_links

        expect(archiver.links).to eq [
          {
            url: 'https://minerals.org.au',
            syndication: nil,
            errors: '502: LiveDocumentNotAvailableException: https://minerals.org.au: live document unavailable: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to req'
          }
        ]
      end
    end

    context 'when there are multiple links' do
      it 'archives them all' do
        archiver.links = [
          { url: 'https://minerals.org.au' },
          { url: 'https://feministinternet.org/' }
        ]

        archiver.archive_links

        expect(archiver.links).to eq [
          {
            url: 'https://minerals.org.au',
            syndication: nil,
            errors: '502: LiveDocumentNotAvailableException: https://minerals.org.au: live document unavailable: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to req'
          },
          {
            url: 'https://feministinternet.org/',
            syndication: 'https://web.archive.org/web/20190312102044/https://feministinternet.org/',
            errors: nil
          }
        ]
      end
    end
  end
end
