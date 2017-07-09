require_relative "test_helper"

module Lexer
  class TestHeaderToken < Petitest::Test
    prepend Petitest::PowerAssert

    def test_scanner
      1.upto(6).each do |i|
        md = "#" * i + " hi"
        assert do
          ::LondonBridge::HeaderToken.scanner.call(md) { |t| @t = t } == "hi" && @t.level == i
        end
      end
    end

    def test_scanner_indentation
      [" # hi", "  # hi", "   # hi"].each do |md|
        assert do
          ::LondonBridge::HeaderToken.scanner.call(md) { |t| @t = t } == "hi" && @t.level == 1
        end
      end
    end

    def test_scanner_too_much_level
      assert do
        ::LondonBridge::HeaderToken.scanner.call("####### hi").nil?
      end
    end

    def test_scanner_after_space_none
      assert do
        ::LondonBridge::HeaderToken.scanner.call("#hi").nil?
      end
    end
  end
end
