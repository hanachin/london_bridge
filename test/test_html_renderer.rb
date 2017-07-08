require_relative "test_helper"

class TestHtmlRenderer < Petitest::Test
  prepend Petitest::PowerAssert

  def test_render
    ast = [::LondonBridge::Lexer::TextToken.new("hi")]
    assert do
      ::LondonBridge::HtmlRenderer.new.render(ast) == "hi"
    end
  end

  def test_on_text
    t = ::LondonBridge::Lexer::TextToken.new("hi")
    assert do
      ::LondonBridge::HtmlRenderer.new.on_text(t) == "hi"
    end
  end
end
