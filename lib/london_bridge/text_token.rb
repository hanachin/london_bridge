require_relative "token"

module LondonBridge
  class TextToken < Struct.new(:text)
    include Token
  end
end
