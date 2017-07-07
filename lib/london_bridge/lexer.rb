module LondonBridge
  class Lexer
    class UnknownTokenError < StandardError; end

    class TextToken < Struct.new(:text); end

    # @param scanners [Array<#call>] the token scanners.
    #   Each scanner should respond to call with a markdown argument,
    #   and yield token to the block, and then return the rest of markdown.
    def initialize(scanners = default_scanners)
      @scanners = scanners
    end

    # @param md [String] the markdown
    # @return [Array<Token>] the tokens of markdown
    # @raise [UnknownTokenError] if failed to identify markdown token
    def lex(md)
      ts = []
      ifnone = -> { raise(UnknownTokenError, md) }
      @scanners.find(ifnone) { |s|
        m = s.call(md) { |t| ts << t } and md = m
      } until md.empty?
      ts
    end

    private

    def default_scanners
      [-> (md, &blk) { blk&.call(TextToken.new(md)); ""  }]
    end
  end
end
