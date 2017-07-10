require_relative "test_helper"

class TestBlockquoteToken < Petitest::Test
  def test_scanner
    assert do
      ::LondonBridge::BlockquoteToken.scanner.call("> hi\n") == "hi\n"
    end
  end

  def test_scanner_spaces
    assert do
      ::LondonBridge::BlockquoteToken.scanner.call("   > hi\n") == "hi\n"
    end
  end

  def test_scanner_nospace
    assert do
      ::LondonBridge::BlockquoteToken.scanner.call(">hi\n") == "hi\n"
    end
  end
end
