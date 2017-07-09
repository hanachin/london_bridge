require_relative "test_helper"

class TestNewlineToken < Petitest::Test
  def test_text
    ::LondonBridge::NewlineToken.new("\n").text == "\n"
  end
end
