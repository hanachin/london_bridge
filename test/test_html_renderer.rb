require_relative "test_helper"

class TestHtmlRenderer < Petitest::Test
  prepend Petitest::PowerAssert
  def test_render
    ast = [
      :root,
      [:header, ::LondonBridge::HeaderToken.new(1), [[:text, ::LondonBridge::TextToken.new("hi")]]]
    ]
    assert do
      ::LondonBridge::HtmlRenderer.new.render(ast) == "<h1>hi</h1>"
    end
  end

  def test_on_text
    t = ::LondonBridge::TextToken.new("hi")
    assert do
      ::LondonBridge::HtmlRenderer.new.on_text(t) == "hi"
    end
  end
end
