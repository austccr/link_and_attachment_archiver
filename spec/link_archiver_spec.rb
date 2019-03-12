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

    pending 'sends the links to the internet archive' do
      expect(archiver.links).to eq [
        {
          url: 'https://feministinternet.org/',
          syndication: 'https://web.archive.org/web/201903120942/https://feministinternet.org/',
          errors: nil
        }
      ]
    end

    context 'if there are errors' do
      pending 'records them' do
        expect(archiver.links).to eq [
          {
            url: 'https://feministinternet.org/',
            syndication: '',
            errors: 'error'
          }
        ]
      end
    end
  end
end
