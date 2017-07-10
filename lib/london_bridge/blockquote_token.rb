require_relative "token"

module LondonBridge
  class BlockquoteToken < Token
    def self.scanner
      lambda do |md, &blk|
        return unless m = md.match(/\A(?: ){0,3}> ?/)
        blk&.call(new(m[0]))
        md[m[0].size..-1]
      end
    end
  end
end
