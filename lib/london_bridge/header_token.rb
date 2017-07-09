require_relative "token"

module LondonBridge
  class HeaderToken < Struct.new(:source)
    include Token

    def self.scanner
      lambda do |md, &blk|
        return unless m = md.match(/\A\#{1,6} +/)
        blk&.call(new(m[0]))
        md[m[0].size..-1]
      end
    end

    def level
      source.count('#')
    end
  end
end
