module LondonBridge
  class IndentToken < Struct.new(:source)
    def self.scanner
      lambda do |md, &blk|
        return unless m = md.match(/\A\t|(?: ){4}/)
        blk&.call(new(m[0]))
        md[m[0].size..-1]
      end
    end
  end
end
