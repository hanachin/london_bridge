require_relative 'fenced_code_helper'

module LondonBridge
  class BlockParser
    class AtxHeadingParser
      def self.parse(input)
        parser = Fiber.new { new(input).parse }
        while event = parser.resume
          yield event
        end
      end

      def initialize(input)
        @input = input
      end

      def parse
        line, lineno = @input.next
        match_opening = /^ {0,3}\#{1,6}[ \t]*/.match(line)
        match_closing = /(?:(?:[ \t]+|^)#+[ \t]*|[ \t]+|)$/.match(match_opening.post_match)
        Fiber.yield AtxHeadingStartEvent.new(lineno, match_opening[0])
        Fiber.yield AtxHeadingInlineContentEvent.new(lineno, match_closing.pre_match)
        Fiber.yield AtxHeadingEndEvent.new(lineno, match_closing[0])
      end
    end
  end
end
