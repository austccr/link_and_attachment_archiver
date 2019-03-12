require_relative '../lib/link_archiver'

RSpec.describe LinkArchiver do
  let(:archiver) { LinkArchiver.new(source_url: '') }

  it 'must have a source url' do
    expect { LinkArchiver.new }.to(
      raise_error(ArgumentError, 'missing keyword: source_url')
    )
  end

  it 'has an attribute links' do
    expect(archiver.links).to eql []
  end

  describe '#parse_html' do
    context 'when there are no links' do
      it 'takes a string of HTML and extracts the links' do
        html = '<p>here is some html</p>'

        archiver.parse_html(html)

        expect(archiver.links).to eql []
      end
    end

    context 'when there is a link' do
      it 'takes a string of HTML and extracts the links' do
        html = '<p>here is some html, with <a href="https://feministinternet.org/">a link</a></p>'

        archiver.parse_html(html)

        expect(archiver.links).to eql [
          { url: 'https://feministinternet.org/' }
        ]
      end
    end

    context 'when there are two links' do
      it 'takes a string of HTML and extracts the links' do
        html = '<p>here is some html, with <a href="https://feministinternet.org/">a link</a></p><div><a href="https://www.forensic-architecture.org/">another link</a></div>'

        archiver.parse_html(html)

        expect(archiver.links).to eql [
          { url: 'https://feministinternet.org/' },
          { url: 'https://www.forensic-architecture.org/' },
        ]
      end
    end
  end
end
