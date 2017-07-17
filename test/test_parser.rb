require_relative "test_helper"

class TestParser < Petitest::Test
  prepend ::Petitest::PowerAssert

  def test_parse_paragraph
    tokens = ::LondonBridge::Lexer.new.lex("hi\nこんにちは")
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:paragraph, [:text, tokens]]]
    end
  end

  def test_parse_indented_content
    tokens = ::LondonBridge::Lexer.new.lex("      hi\n    こんにちは\n")
    indent, l1, newline, _indent, l2, _newline = tokens
    expected_ast = [
      :root,
      [:codeblock, [:code, [l1, newline, l2, newline]]]
    ]
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == expected_ast
    end
  end

  def test_parse_not_indented_content
    tokens = ::LondonBridge::Lexer.new.lex("      hi\nこんにちは\n")
    indent, l1, newline, l2, _newline = tokens
    expected_ast = [
      :root,
      [:codeblock, [:code, [l1, newline]]],
      [:paragraph, [:text, [l2, newline]]],
    ]
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == expected_ast
    end
  end

  def test_parse_themantic_break_token
    tokens = ::LondonBridge::Lexer.new.lex("***\n")
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:hr]]
    end
  end

  def test_parse_too_many_themantic_break_token
    tokens = ::LondonBridge::Lexer.new.lex("    ***\n")
    _indent, thematic_break_token, newline = tokens
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:codeblock, [:code, [thematic_break_token]]]]
    end
  end

  def test_parse_blockquote
    tokens = ::LondonBridge::Lexer.new.lex("> hi\nhi\n> hi\n")
    _blockquote, text, newline, _text, _newline, _blockquote, _text, _newline = tokens
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:blockquote, [[:paragraph, [:text, [text, newline, text, newline, text]]]]]]
    end
  end

  def test_parse_code
    tokens = ::LondonBridge::Lexer.new.lex("`hi`\n")
    special, text, special, newline = tokens
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:paragraph, [:code, [text]]]]
    end
  end
end
