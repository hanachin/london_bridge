require_relative "test_helper"

class TestThematicBreakToken < Petitest::Test
  prepend Petitest::PowerAssert

  def test_scanner_asterisk
    assert do
      ::LondonBridge::ThematicBreakToken.scanner.call("***\nhi\n") == "hi\n"
    end
  end

  def test_scanner_hyphen
    assert do
      ::LondonBridge::ThematicBreakToken.scanner.call("---\nhi\n") == "hi\n"
    end
  end

  def test_scanner_underscore
    assert do
      ::LondonBridge::ThematicBreakToken.scanner.call("___\nhi\n") == "hi\n"
    end
  end

  def test_scanner_pre_spaces
    assert do
      [
        ::LondonBridge::ThematicBreakToken.scanner.call(" ***\nhi\n") == "hi\n",
        ::LondonBridge::ThematicBreakToken.scanner.call("  ***\nhi\n") == "hi\n",
        ::LondonBridge::ThematicBreakToken.scanner.call("   ***\nhi\n") == "hi\n",
      ].all?
    end
  end

  def test_scanner_more_characters
    assert do
      ::LondonBridge::ThematicBreakToken.scanner.call("********\nhi\n") == "hi\n"
    end
  end

  def test_scanner_spaces_between_characters
    assert do
      [
        ::LondonBridge::ThematicBreakToken.scanner.call("* * *\nhi\n") == "hi\n",
        ::LondonBridge::ThematicBreakToken.scanner.call("*    **\nhi\n") == "hi\n",
        ::LondonBridge::ThematicBreakToken.scanner.call("*    *      *     ") == "",
        ::LondonBridge::ThematicBreakToken.scanner.call("*\t*\t*\t") == "",
        ::LondonBridge::ThematicBreakToken.scanner.call("*   *   \nhi\n").nil?,
      ].all?
    end
  end

  def test_scanner_4spaces
    assert do
      ::LondonBridge::ThematicBreakToken.scanner.call("    ***\n").nil?
    end
  end

  def test_scanner_mixed_character
    assert do
      ::LondonBridge::ThematicBreakToken.scanner.call("*-*\n").nil?
    end
  end
end
