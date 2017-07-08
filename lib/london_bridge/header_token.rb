require_relative "token"

module LondonBridge
  class HeaderToken < Struct.new(:level)
    include Token

    def self.scanner
      lambda do |md, &blk|
        return unless m = md.match(/\A\#{1,6} /)
        blk&.call(new(m[0].size - 1))
        md[m[0].size..-1]
      end
    end
  end
end
