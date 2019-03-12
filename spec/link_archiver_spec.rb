require_relative '../lib/link_archiver'

RSpec.describe LinkArchiver do
  it 'must have a source url' do
    expect { LinkArchiver.new }.to(
      raise_error(ArgumentError, 'missing keyword: source_url')
    )
  end

  describe '#parse_html' do
    let(:archiver) { LinkArchiver.new(source_url: 'https://foo.org/bar') }

    context 'when there are no links' do
      it 'it finds none' do
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

    context 'with a relative URL' do
      it 'it makes it absolute' do
        html = '<p>here is some html, with <a href="/files/foobar">a link</a></p>'

        archiver.parse_html(html)

        expect(archiver.links).to eql [
          { url: 'https://foo.org/files/foobar' }
        ]
      end
    end

    context 'when there are duplicate links' do
      it 'takes a string of HTML and extracts the links' do
        html = '<p>here is some html, with <a href="https://feministinternet.org/">a link</a></p><div><a href="https://feministinternet.org/">a duplicate link</a></div>'

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

    context 'example.html' do
      it 'extracts URLs' do
        archiver.source_url = 'http://minerals.org.au/news/peru-australia-free-trade-agreement-will-deliver-investment-and-jobs-australia'
        html = File.read('./spec/fixtures/example.html')

        archiver.parse_html(html)

        expect(archiver.links).to eql [
          { url: 'http://minerals.org.au/files/190226-peru-australia-free-trade-agreement-will-deliver-investment-and-jobs-australiapdf' },
          { url: 'https://minerals.org.au/sites/default/files/190226%20Peru-Australia%20Free%20Trade%20Agreement%20will%20deliver%20investment%20and%20jobs%20for%20Australia.pdf' }
        ]
      end
    end
  end
end
