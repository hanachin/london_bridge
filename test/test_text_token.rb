require_relative "test_helper"

class TestTextToken < Petitest::Test
  def test_backslash_escape
    @ts = []
    md = '\\!\\"\\#\\$\\%\\&\\\'\\(\\)\\*\\+\\,\\-\\.\\/\\:\\;\\<\\=\\>\\?\\@\\[\\\\\\]\\^\\_\\`\\{\\|\\}\\~\\あ'
    ::LondonBridge::TextToken.scanner.call(md) do |t|
      @ts << t
    end

    assert do
      @ts.map(&:text).join == '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~\\あ'
    end
  end
end
