require_relative "token"

module LondonBridge
  class NewlineToken < Token
    alias text source
  end
end
