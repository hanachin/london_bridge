require_relative "token"

module LondonBridge
  class ThematicBreakToken < Struct.new(:hr)
    include Token

    def self.scanner
      lambda do |md, &blk|
        return unless m = md.match(/\A[ ]{0,3}(\*|-|_)(?:[\t ]*\1){2}(?:\t| |\1)*(?:\R|\z)/)
        blk&.call(ThematicBreakToken.new(m[0]))
        md[m[0].size..-1]
      end
    end
  end
end
