# frozen_string_literal: true

RSpec.describe ReleaseAssistant::Parser do
  subject(:parser) { ReleaseAssistant::Parser.new(options) }

  let(:options) { stubbed_slop_options('the_search_string --repo username/reponame') }

  before do
    expect($stdin).to receive(:each) do |_stdin, &blk|
      StringIO.new(stubbed_stdin).each(&blk)
    end
  end

  describe '#parse' do
    subject(:parse) { parser.parse }

    let(:stubbed_stdin) do
      <<~STUBBED_STDIN
        commit Add rubocop as a development dependency|066c52f44a3977f55c1b457a25f084b66856bc41|David Runger|3 days ago (2019-12-28 10:33:45 -0800)
        diff --git a/lib/release_assistant/version.rb b/lib/release_assistant/version.rb
        - this line matches the_search_string!
        + this line also matches the_search_string!
        + this line doesn't match the search string
      STUBBED_STDIN
    end

    it 'prints stuff' do
      expect($stdout).to receive(:puts).with([
        'Add rubocop as a development dependency',
        '066c52f ( https://github.com/username/reponame/commit/066c52f )',
        'David Runger',
        '3 days ago (2019-12-28 10:33:45 -0800)',
      ]).ordered
      expect($stdout).to receive(:puts).
        with('==============================================').ordered
      expect($stdout).to receive(:puts).with('lib/release_assistant/version.rb').ordered
      expect($stdout).to receive(:puts).
        with("\e[0;31;49m- this line matches the_search_string!\e[0m").ordered
      expect($stdout).to receive(:puts).
        with("\e[0;32;49m+ this line also matches the_search_string!\e[0m").ordered

      parse
    end
  end
end
