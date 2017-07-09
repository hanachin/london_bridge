require_relative "token"

module LondonBridge
  class NewlineToken < Struct.new(:newline)
    include Token
  end
end
