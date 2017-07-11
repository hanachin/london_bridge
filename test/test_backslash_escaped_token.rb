require_relative "test_helper"

class TestBackslashEscapedToken
  def test_text
    token = ::LondonBridge::BackslashEscapedToken.new('\*')
    assert do
      token.text == "*"
    end
  end
end
