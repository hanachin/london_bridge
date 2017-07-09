require_relative "unknown_token_error"
require_relative "text_token"
require_relative "header_token"
require_relative "blank_line_token"
require_relative "thematic_break_token"

module LondonBridge
  class Lexer
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
      [
        HeaderToken.scanner,
        ThematicBreakToken.scanner,
        BlankLineToken.scanner,
        TextToken.scanner,
      ]
    end
  end
end
