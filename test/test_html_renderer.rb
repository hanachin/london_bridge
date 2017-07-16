require_relative "test_helper"

class TestHtmlRenderer < Petitest::Test
  prepend Petitest::PowerAssert

  def parse(md)
    ::LondonBridge::Parser.new.parse(::LondonBridge::Lexer.new.lex(md))
  end

  def test_header
    ast = parse("#       hi")
    assert do
      ::LondonBridge::HtmlRenderer.new.render(ast) == "<h1>hi</h1>"
    end
  end

  def test_paragraph
    ast = parse("hi")
    assert do
      ::LondonBridge::HtmlRenderer.new.render(ast) == "<p>hi</p>"
    end
  end

  def test_hr
    ast = parse("***\n")
    assert do
      ::LondonBridge::HtmlRenderer.new.render(ast) == "<hr />"
    end
  end

  def test_codeblock
    ast = parse("      hi\n    こんにちは\n")
    assert do
      ::LondonBridge::HtmlRenderer.new.render(ast) == "<pre><code>  hi\nこんにちは\n</code></pre>"
    end
  end

  def test_blockquote
    ast = parse("> hi\nhi")
    assert do
      ::LondonBridge::HtmlRenderer.new.render(ast) == "<blockquote><p>hi\nhi</p></blockquote>"
    end
  end
end
