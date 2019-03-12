require_relative '../lib/link_archiver'

RSpec.describe LinkArchiver do
  it 'must have a source url' do
    expect { LinkArchiver.new }.to(
      raise_error(ArgumentError, 'missing keyword: source_url')
    )
  end
end
