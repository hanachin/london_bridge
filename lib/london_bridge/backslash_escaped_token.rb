require_relative "text_token"

module LondonBridge
  class BackslashEscapedToken < TextToken
    def text
      source[1]
    end
  end
end
