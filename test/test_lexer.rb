require_relative "test_helper"

class TestLexer < Petitest::Test
  include ::Petitest::Assertions
  prepend ::Petitest::PowerAssert

  def test_plaintext
    assert do
      ::LondonBridge::Lexer.new.lex("#       hi") == [
        ::LondonBridge::HeaderToken.new("#       "),
        ::LondonBridge::TextToken.new("hi")
      ]
    end
  end

  def test_failed_to_identify_token
    assert_raise(::LondonBridge::UnknownTokenError) do
      ::LondonBridge::Lexer.new([]).lex("hi")
    end
  end

  def test_thematic_break_token
    assert do
      ::LondonBridge::Lexer.new.lex("***\n") == [::LondonBridge::ThematicBreakToken.new("***\n")]
    end
  end

  def test_thematic_break_token
    assert do
      ::LondonBridge::Lexer.new.lex("      hi\n") == [::LondonBridge::IndentToken.new("    "), ::LondonBridge::TextToken.new("  hi"), ::LondonBridge::NewlineToken.new("\n")]
    end
  end

  def test_blockquote
    assert do
      ::LondonBridge::Lexer.new.lex("> hi\n") == [::LondonBridge::BlockquoteToken.new("> "), ::LondonBridge::TextToken.new("hi"), ::LondonBridge::NewlineToken.new("\n")]
    end
  end
end
