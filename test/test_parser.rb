require_relative "test_helper"

class TestParser < Petitest::Test
  prepend ::Petitest::PowerAssert

  def test_parse
    tokens = [::LondonBridge::TextToken.new("hi")]
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:paragraph, [:text, *tokens]]]
    end
  end

  def test_parse_themantic_break_token
    tokens = [::LondonBridge::ThematicBreakToken.new("***\n")]
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:hr]]
    end
  end
end
