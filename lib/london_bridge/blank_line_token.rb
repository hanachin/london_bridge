module LondonBridge
  class BlankLineToken < Struct.new(:blank_line)
    include Token

    def self.scanner
      lambda do |md, &blk|
        return unless m = md.match(/\A^\R/)
        blk&.call(new(m[0]))
        md[m[0].size..-1]
      end
    end
  end
end