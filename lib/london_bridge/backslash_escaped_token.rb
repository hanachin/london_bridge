require_relative "text_token"

module LondonBridge
  class TextToken < Token; end

  class BackslashEscapedToken < TextToken
    def text
      source[1]
    end
  end
end
