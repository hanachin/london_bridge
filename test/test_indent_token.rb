require_relative "test_helper"

class TestIndentToken < Petitest::Test
  prepend Petitest::PowerAssert

  def test_scanner_spaces
    scanner = ::LondonBridge::IndentToken.scanner
    assert do
      scanner.call("      \n") == "  \n"
    end
  end

  def test_scanner_tab
    scanner = ::LondonBridge::IndentToken.scanner
    assert do
      scanner.call("\t\t\n") == "\t\n"
    end
  end

  def test_scanner_spaces_and_tab
    scanner = ::LondonBridge::IndentToken.scanner
    assert do
      scanner.call("  \t\t\n") == "\t\n"
    end
  end
end