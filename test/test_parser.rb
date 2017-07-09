require_relative "test_helper"

class TestParser < Petitest::Test
  prepend ::Petitest::PowerAssert

  def test_parse
    tokens = [::LondonBridge::TextToken.new("hi")]
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:paragraph, [:text, *tokens]]]
    end
  end
end
