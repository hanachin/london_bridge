require_relative 'fenced_code_helper'

module LondonBridge
  class BlockParser
    class UnorderedListParser
      def self.parse(input, list_level)
        parser = Fiber.new { new(input, list_level).parse }
        while event = parser.resume
          yield event
        end
      end

      def initialize(input, list_level)
        @input = input
        @start_line, @start_lineno = input.peek
        @list_level = list_level
      end

      def parse
        line, lineno = @input.next

        binding.pry
        start_line_indent = /^ {0,3}(?:\-|\+|\*)(?: {1,4}(?! ))(?!-|\+|\*)/.match(line)[0].size
        original_lines = {}
        new_input = Enumerator.new do |y|
          original_lines[lineno] = line
          y << [line[start_line_indent..-1], lineno]
          loop do
            line, lineno = @input.peek
            if !line.match(/^ {#{start_line_indent}}/) && !line.match(/^\s*$/)
              raise StopIteration
            end
            line, lineno = @input.next
            original_lines[lineno] = line
            y << [line.sub(/^ #{start_line_indent}/, ''), lineno]
          end
        end

        start_event = ListItemStartEvent.new(lineno, line, list_level: @list_level)

        children = ::LondonBridge::BlockParser.new(new_input, list_level: @list_level + 1).map do |e|
          ListItemInlineContentEvent.new(e.lineno, original_lines.fetch(e.lineno), child: e)
        end

        end_event = ListItemEndEvent.new(lineno, line, list_level: @list_level)

        children2 = children.map(&:child).reverse_each.drop_while { |e|
          e.kind_of?(BlankLinesStartEvent) ||
            e.kind_of?(BlankLinesInlineContentEvent) ||
            e.kind_of?(BlankLinesEndEvent)
        }
        if children2.first.kind_of?(UnOrderedListEndEvent)
          children2 = children2.drop_while {|e| !e.kind_of?(UnOrderedListStartEvent) }.drop(1)
        end
        tight = children2.map(&:source).compact.join.count("\n") <= 1 && !children2.any? {|e|
          e.kind_of?(IndentedCodeStartEvent) ||
            e.kind_of?(ThematicBreakStartEvent)
        }
        [start_event, end_event].each do |e|
          e.options[:tight] = tight
        end

        Fiber.yield start_event
        children.each { |child| Fiber.yield child }
        Fiber.yield end_event
      end
    end
  end
end
