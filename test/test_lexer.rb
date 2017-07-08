require_relative "test_helper"

class TestLexer < Petitest::Test
  include ::Petitest::Assertions
  prepend ::Petitest::PowerAssert

  def test_plaintext
    assert do
      ::LondonBridge::Lexer.new.lex("hi") == [::LondonBridge::TextToken.new("hi")]
    end
  end

  def test_failed_to_identify_token
    assert_raise(::LondonBridge::UnknownTokenError) do
      ::LondonBridge::Lexer.new([]).lex("hi")
    end
  end
end
