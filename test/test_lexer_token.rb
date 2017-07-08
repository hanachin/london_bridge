require_relative "test_helper"

module Lexer
  class TestToken < Petitest::Test
    prepend Petitest::PowerAssert

    def test_token_name
      assert do
        ::LondonBridge::Lexer::TextToken.token_name == "text"
      end
    end

    def test_name
      assert do
        ::LondonBridge::Lexer::TextToken.new("hi").name == "text"
      end
    end
  end
end
