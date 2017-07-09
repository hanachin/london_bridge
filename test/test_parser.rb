require_relative "test_helper"

class TestParser < Petitest::Test
  prepend ::Petitest::PowerAssert

  def test_parse_paragraph
    tokens = [
      ::LondonBridge::TextToken.new("hi"),
      ::LondonBridge::NewlineToken.new("\n"),
      ::LondonBridge::TextToken.new("こんにちは"),
    ]
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:paragraph, [:text, tokens]]]
    end
  end

  def test_parse_indented_content
    indent = ::LondonBridge::IndentToken.new("    ")
    l1 = ::LondonBridge::TextToken.new("  hi")
    newline = ::LondonBridge::NewlineToken.new("\n")
    l2 = ::LondonBridge::TextToken.new("こんにちは")
    tokens = [
      indent, l1, newline,
      indent, l2, newline,
    ]
    expected_ast = [
      :root,
      [:codeblock, [:text, [l1, newline, l2, newline]]]
    ]
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == expected_ast
    end
  end


  def test_parse_indented_content
    indent = ::LondonBridge::IndentToken.new("    ")
    l1 = ::LondonBridge::TextToken.new("  hi")
    newline = ::LondonBridge::NewlineToken.new("\n")
    l2 = ::LondonBridge::TextToken.new("こんにちは")
    tokens = [
      indent, l1, newline,
      indent, l2, newline,
    ]
    expected_ast = [
      :root,
      [:codeblock, [:code, [l1, newline, l2, newline]]]
    ]
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == expected_ast
    end
  end

  def test_parse_not_indented_content
    indent = ::LondonBridge::IndentToken.new("    ")
    l1 = ::LondonBridge::TextToken.new("  hi")
    newline = ::LondonBridge::NewlineToken.new("\n")
    l2 = ::LondonBridge::TextToken.new("こんにちは")
    tokens = [
      indent, l1, newline,
      l2, newline,
    ]
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
    tokens = [::LondonBridge::ThematicBreakToken.new("***\n")]
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:hr]]
    end
  end

  def test_parse_too_many_themantic_break_token
    thematic_break_token = ::LondonBridge::ThematicBreakToken.new("***\n")
    tokens = [
      ::LondonBridge::IndentToken.new("    "),
      thematic_break_token
    ]
    assert do
      ::LondonBridge::Parser.new.parse(tokens) == [:root, [:codeblock, [:code, [thematic_break_token]]]]
    end
  end
end
