module LondonBridge
  class IndentToken < Token
    def self.scanner
      lambda do |md, &blk|
        return unless m = md.match(/\A(?: ){4}|\A(?: ){0,3}\t/)
        blk&.call(new(m[0]))
        md[m[0].size..-1]
      end
    end
  end
end
