require_relative '../lib/link_archiver'

RSpec.describe LinkArchiver do
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

    context 'example_02.html' do
      let(:html) { File.read('./spec/fixtures/example_02.html') }

      before do
        archiver.source_url = 'http://minerals.org.au/news/exceptional-victorian-women-resources-sought-2019-awards'
      end

      it 'extracts URLs' do
        is_expected.to eql [
          { url: 'http://minerals.org.au/events/victorian-women-resources-awards-2019' },
          { url: 'http://minerals.org.au/files/190308-exceptional-victorian-women-resources-sought-2019-awardspdf-0' },
          { url: 'https://minerals.org.au/sites/default/files/190308%20Exceptional%20Victorian%20women%20in%20resources%20sought%20for%202019%20awards_0.pdf' }
        ]
      end
    end

    context 'example_03.html' do
      let(:html) { File.read('./spec/fixtures/example_03.html') }

      before do
        archiver.source_url = 'http://minerals.org.au/news/powering-future-australian-mining-people-innovation-and-modern-education'
      end

      it 'extracts URLs' do
        is_expected.to eql [
          { url: 'https://www.minerals.org.au/news/future-work-changing-skills-landscape-miners' },
          { url: 'https://www.minerals.org.au/news/future-work-economic-implications-technology-and-digital-mining' },
          { url: 'http://minerals.org.au/files/190214-powering-future-australian-mining-people-innovation-and-modern-educationpdf' },
          { url: 'https://minerals.org.au/sites/default/files/190214%20Powering%20the%20future%20of%20Australian%20mining%20with%20people%20innovation%20and%20modern%20education.pdf' }
        ]
      end
    end

    context 'example_04.html' do
      let(:html) { File.read('./spec/fixtures/example_04.html') }

      before do
        archiver.source_url = 'http://minerals.org.au/news/new-campaign-shows-there%E2%80%99s-more-australian-mining'
      end

      it 'extracts URLs' do
        is_expected.to eql [
          { url: 'https://www.youtube.com/watch?v=uDgGTjJ1KnY' },
          { url: 'http://minerals.org.au/files/190211-new-campaign-shows-theres-more-australian-miningpdf-0' },
          { url: 'https://minerals.org.au/sites/default/files/190211%20New%20campaign%20shows%20there%27s%20more%20to%20Australian%20mining_0.pdf' }
        ]
      end
    end

    context 'example_05.html' do
      let(:html) { File.read('./spec/fixtures/example_05.html') }

      before do
        archiver.source_url = 'http://minerals.org.au/news/tpp-11-ratification-great-news-australian-jobs-and-workers'
      end

      it 'extracts URLs' do
        is_expected.to eql [
          { url: 'http://www.minerals.org.au/sites/default/files/180905%20Australia%20will%20gain%20from%20continued%20Asia-Pacific%20trade%20integration.pdf' },
          { url: 'https://www.lowyinstitute.org/publications/2017-lowy-institute-poll#section_32816' },
          { url: 'http://minerals.org.au/files/181031-tpp-11-ratification-great-news-australian-jobs-and-workerspdf' },
          { url: 'http://minerals.org.au/sites/default/files/181031%20TPP-11%20ratification%20great%20news%20for%20Australian%20jobs%20and%20workers.pdf' }
        ]
      end
    end

    context 'example_06.html' do
      let(:html) { File.read('./spec/fixtures/example_06.html') }

      before do
        archiver.source_url = 'http://minerals.org.au/news/australia%E2%80%99s-world-class-minerals-industry-shows-global-leadership-sustainability'
      end

      it 'extracts URLs' do
        is_expected.to eql [
          { url: 'https://www.minerals.org.au/sites/default/files/Sustainability%20in%20Action%20October%202018%20WEB_0.pdf' },
          { url: 'http://minerals.org.au/files/181030-australia%E2%80%99s-world-class-minerals-industry-shows-global-leadership-sustainabilitypdf' },
          { url: 'http://minerals.org.au/sites/default/files/181030%20Australia%E2%80%99s%20world-class%20minerals%20industry%20shows%20global%20leadership%20on%20sustainability.pdf' },
          { url: 'http://minerals.org.au/files/sustainability-action-report-october-2018pdf' },
          { url: 'http://minerals.org.au/sites/default/files/Sustainability%20in%20Action%20October%202018%20WEB_0.pdf' }
        ]
      end
    end

    context 'example_07.html' do
      let(:html) { File.read('./spec/fixtures/example_07.html') }

      before do
        archiver.source_url = 'http://minerals.org.au/news/austmine-mca-mou-strengthens-minings-sustainability'
      end

      it 'extracts URLs' do
        is_expected.to eql [
          { url: 'http://www.austmine.com.au' },
          { url: 'http://minerals.org.au/file/420' },
          { url: 'http://minerals.org.au/sites/default/files/Austmine_MCA_MOU_October_2013.pdf' }
        ]
      end
    end

    context 'example_08.html' do
      let(:html) { File.read('./spec/fixtures/example_08.html') }

      before do
        archiver.source_url = 'http://minerals.org.au/news/minister_canavan_on_target_in_supporting_coal_industry_and_jobs'
      end

      it 'extracts URLs' do
        is_expected.to eql [
          { url: 'http://minerals.org.au/app/private/Media_statement_-_Minister_Canavan_on_target_in_supporting_coal_industry_and_jobs_5_Jan_2017%20%281%29.pdf' }
        ]
      end
    end

    context 'example_09.html' do
      let(:html) { File.read('./spec/fixtures/example_09.html') }

      before do
        archiver.source_url = 'http://minerals.org.au/new_report_backs_carbon_capture_and_storage_in_australia'
      end

      it 'extracts URLs' do
        is_expected.to eql [
          { url: 'http://www.minerals.org.au/file_upload/files/publications/UQE003_CCS_report_HR.PDF' },
          { url: 'http://minerals.org.au/UQE003_CCS_report_HR.PDF' },
          { url: 'http://minerals.org.au/WP1_Energy_and_Climate.pdf' },
          { url: 'http://www.minerals.org.au/file_upload/files/publications/WP1_Energy_and_Climate.pdf' },
          { url: 'http://www.minerals.org.au/file_upload/files/publications/WP2_Financial_Incentives.pdf' },
          { url: 'http://www.minerals.org.au/file_upload/files/publications/WP3_CCS_Roadmaps_and_Projects.pdf' }
        ]
      end
    end
  end
end
