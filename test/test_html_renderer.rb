require_relative "test_helper"

class TestHtmlRenderer < Petitest::Test
  prepend Petitest::PowerAssert

  def test_on_header
    header_token = ::LondonBridge::HeaderToken.new("#       ")
    text_token = ::LondonBridge::TextToken.new("hi")
    ast = [:header, header_token, [[:text, [text_token]]]]

    assert do
      ::LondonBridge::HtmlRenderer.new.render(ast) == "<h1>hi</h1>"
    end
  end

  def test_on_text
    t = ::LondonBridge::TextToken.new("hi")
    assert do
      ::LondonBridge::HtmlRenderer.new.on_text([t]) == "hi"
    end
  end

  def test_on_hr
    assert do
      ::LondonBridge::HtmlRenderer.new.on_hr == "<hr />"
    end
  end

  def test_on_codeblock
    l1 = ::LondonBridge::TextToken.new("  hi")
    l2 = ::LondonBridge::TextToken.new("こんにちは")
    newline = ::LondonBridge::NewlineToken.new("\n")
    ast = [:codeblock, [:code, [l1, newline, l2, newline]]]
    assert do
      ::LondonBridge::HtmlRenderer.new.render(ast) == "<pre><code>  hi\nこんにちは\n</code></pre>"
    end
  end

  def test_on_blockquote
    blockquote = ::LondonBridge::BlockquoteToken.new("> ")
    text = ::LondonBridge::TextToken.new("hi")
    newline = ::LondonBridge::NewlineToken.new("\n")
    ast = [:blockquote, [[:paragraph, [:text, [text, newline, text]]]]]
    assert do
      ::LondonBridge::HtmlRenderer.new.render(ast) == "<blockquote><p>hi\nhi</p></blockquote>"
    end
  end
end
