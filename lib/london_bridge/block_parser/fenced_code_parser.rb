require_relative 'fenced_code_helper'

module LondonBridge
  class BlockParser
    class FencedCodeParser
      using FencedCodeHelper

      def self.parse(input)
        parser = Fiber.new { new(input).parse }
        while event = parser.resume
          yield event
        end
      end

      def parse
        start_line, start_lineno = @input.next
        start_event = FencedCodeStartEvent.new(
          start_lineno,
          start_line,
          indent: indent,
          info_string: info_string
        )
        Fiber.yield(start_event)

        while true
          line, lineno = @input.next
          break if closing_code_fence?(line)
          Fiber.yield(FencedCodeInlineContentEvent.new(lineno, line, indent: indent))
        end
      ensure
        end_event = FencedCodeEndEvent.new(lineno, line)
        Fiber.yield(end_event)
      end

      def initialize(input)
        @input = input
        @start_line, _start_lineno = @input.peek
        @opening_code_fence = @start_line.opening_code_fence
      end

      private

      def closing_code_fence?(line)
        line.closing_code_fence_of?(@opening_code_fence)
      end

      def indent
        @start_line.code_fence_indentation
      end

      def info_string
        @start_line.code_fence_info_string
      end
    end
  end
end
