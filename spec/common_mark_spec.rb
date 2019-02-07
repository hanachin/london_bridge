require "json"
require "stringio"

COMMON_MARK_DUMPED_TESTS_PATH = File.expand_path("../tests.json", __dir__)
COMMON_MARK_TESTS_JSON = File.read(COMMON_MARK_DUMPED_TESTS_PATH)
COMMON_MARK_TESTS = JSON.parse(COMMON_MARK_TESTS_JSON)

COMMON_MARK_TESTS.group_by {|t| t["section"] }.each do |section, tests|
  RSpec.describe section, section.to_sym do
    tests.each do |t|
      example t["example"] do
        input = StringIO.new(t["markdown"])
        parser = LondonBridge::BlockParser.new(input)
        output = StringIO.new
        renderer = LondonBridge::HtmlRenderer.new(parser, output)
        renderer.render
        expect(output.string).to eq(t["html"])
      end
    end
  end
end
