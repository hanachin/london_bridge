require_relative "test_helper"

class TestTextToken < Petitest::Test
  prepend Petitest::PowerAssert

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

  def test_special_tokens
    @ts = []
    md = "`*_![]()#"
    rest = ::LondonBridge::TextToken.scanner.call(md) do |t|
      @ts << t
    end

    assert do
      rest == ""
    end

    assert do
      @ts == md.chars.map { |c| ::LondonBridge::SpecialToken.new(c) }
    end
  end
end
