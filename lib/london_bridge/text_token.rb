require_relative "token"
require_relative "newline_token"

module LondonBridge
  class TextToken < Struct.new(:text)
    include Token

    def self.scanner
      lambda do |md, &blk|
        return unless m = md.match(/\A(.+$)(\R)?/)

        blk&.call(TextToken.new(m[1]))
        blk&.call(NewlineToken.new(m[2])) if m[2]

        md[m[0].size..-1]
      end
    end
  end
end
