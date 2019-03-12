require_relative '../lib/link_archiver'

RSpec.describe LinkArchiver do
  it 'must have a source url' do
    expect { LinkArchiver.new }.to(
      raise_error(ArgumentError, 'missing keyword: source_url')
    )
  end

  describe '#parse_html' do
    let(:archiver) { LinkArchiver.new(source_url: 'https://foo.org/bar') }

    subject do
      archiver.parse_html(html)
      archiver.links
    end

    context 'when there are no links' do
      let(:html) { '<p>here is some html</p>' }

      it 'it finds none' do
        is_expected.to eql []
      end
    end

    context 'when there is a link' do
      let(:html) { '<p>here is some html, with <a href="https://feministinternet.org/">a link</a></p>' }

      it 'takes a string of HTML and extracts the links' do
        is_expected.to eql [ { url: 'https://feministinternet.org/' } ]
      end
    end

    context 'with a relative URL' do
      let(:html) { '<p>here is some html, with <a href="/files/foobar">a link</a></p>' }

      it 'it makes it absolute' do
        is_expected.to eql [
          { url: 'https://foo.org/files/foobar' }
        ]
      end
    end

    context 'when there are duplicate links' do
      let(:html) { '<p>here is some html, with <a href="https://feministinternet.org/">a link</a></p><div><a href="https://feministinternet.org/">a duplicate link</a></div>' }

      it 'takes a string of HTML and extracts the links' do
        is_expected.to eql [
          { url: 'https://feministinternet.org/' }
        ]
      end
    end

    context 'when there are two links' do
      let(:html) { '<p>here is some html, with <a href="https://feministinternet.org/">a link</a></p><div><a href="https://www.forensic-architecture.org/">another link</a></div>' }

      it 'takes a string of HTML and extracts the links' do
        is_expected.to eql [
          { url: 'https://feministinternet.org/' },
          { url: 'https://www.forensic-architecture.org/' },
        ]
      end
    end

    context 'duplicate_example.html' do
      let(:html) { File.read('./spec/fixtures/duplicate_example.html') }

      before do
        archiver.source_url = 'https://minerals.org.au/news/peru-australia-free-trade-agreement-will-deliver-investment-and-jobs-australia'
      end

      it 'extracts unique URLs' do
        is_expected.to eql [
          { url: 'https://minerals.org.au/sites/default/files/190226%20Peru-Australia%20Free%20Trade%20Agreement%20will%20deliver%20investment%20and%20jobs%20for%20Australia.pdf' }
        ]
      end
    end

    context 'example.html' do
      let(:html) { File.read('./spec/fixtures/example.html') }

      before do
        archiver.source_url = 'http://minerals.org.au/news/peru-australia-free-trade-agreement-will-deliver-investment-and-jobs-australia'
      end

      it 'extracts URLs' do
        is_expected.to eql [
          { url: 'http://minerals.org.au/files/190226-peru-australia-free-trade-agreement-will-deliver-investment-and-jobs-australiapdf' },
          { url: 'https://minerals.org.au/sites/default/files/190226%20Peru-Australia%20Free%20Trade%20Agreement%20will%20deliver%20investment%20and%20jobs%20for%20Australia.pdf' }
        ]
      end
    end

    context 'example_01.html' do
      let(:html) { File.read('./spec/fixtures/example_01.html') }

      before do
        archiver.source_url = 'http://minerals.org.au/news/mca-calls-parliament-support-regional-communities-and-jobs'
      end

      it 'extracts URLs' do
        is_expected.to eql [
          { url: 'http://minerals.org.au/files/190220-mca-calls-parliament-support-regional-communities-and-jobspdf' },
          { url: 'https://minerals.org.au/sites/default/files/190220%20MCA%20calls%20on%20Parliament%20to%20support%20regional%20communities%20and%20jobs.pdf' }
        ]
      end
    end
  end
end
