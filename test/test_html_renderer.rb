require_relative "test_helper"

class TestHtmlRenderer < Petitest::Test
  prepend Petitest::PowerAssert

  def test_on_header
    header_token = ::LondonBridge::HeaderToken.new(1)
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
end
