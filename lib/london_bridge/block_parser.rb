require_relative 'block_parser/detab'
require_relative 'block_parser/events'
require_relative 'block_parser/markers'
require_relative 'block_parser/atx_heading_parser'
require_relative 'block_parser/fenced_code_parser'
require_relative 'block_parser/unordered_list_parser'

module LondonBridge
  class BlockParser
    include Enumerable

    using Detab
    using FencedCodeHelper
    using Markers

    def initialize(input, list_level: 1)
      @input = input
      @paragraph = []
      @list_level = list_level
    end

    def each
      def input.peek
        line, lineno = super
        [line.detab, lineno]
      end

      def input.next
        line, lineno = super
        [line.detab, lineno]
      end

      last_lineno = 0
      @ul_continue = false
      loop do
        line, lineno = input.peek
        @last_lineno = lineno
        ul_hit = false
        case
        when line.thematic_break?
          end_ul {|e| yield  e }
          end_paragraph { |p| yield  p }
          parse_thematic_break(input) { |tb| yield tb }
        when line.atx_heading?
          end_ul {|e| yield  e }
          end_paragraph { |p| yield p }
          parse_atx_heading(input) { |ah| yield ah }
        when line.fenced_code_block?
          end_ul {|e| yield  e }
          end_paragraph { |p| yield p }
          parse_fenced_code(input) { |fc| yield fc }
        when line.indented_code_block?
          if  @paragraph.empty?
            end_ul {|e| yield  e }
            end_paragraph { |p| yield p }
            parse_indented_code(input) { |event| yield event }
          else
            end_ul {|e| yield  e }
            add_paragraph(input)
          end
        when line.blank_line?
          end_ul {|e| yield  e }
          end_paragraph { |p| yield p }
          parse_blank_lines(input) { |event| yield event }
        when line.block_quotes?
          end_ul {|e| yield  e }
          end_paragraph { |p| yield p }
          parse_blockquote(input) { |event| yield event }
        when line.bullet_list?
          end_paragraph { |p| yield p }
          unless @ul_continue
            yield UnOrderedListStartEvent.new(lineno, '')
          end
          parse_unordered_list(input) { |event| yield event }
          ul_hit = true
        else
          end_ul {|e| yield  e }
          add_paragraph(input)
        end
        @ul_continue = ul_hit
      end
      end_ul {|e| yield  e }
      end_paragraph { |p| yield p }
    end

    private

    attr_reader :input

    def end_ul
      yield UnOrderedListEndEvent.new(@last_lineno, '') if @ul_continue
    end

    def add_paragraph(input)
      source, lineno = input.next
      if @paragraph.empty?
        @paragraph << ParagraphStartEvent.new(lineno, '')
        @paragraph << ParagraphInlineContentEvent.new(lineno, source)
      else
        @paragraph << ParagraphInlineContentEvent.new(lineno, source)
      end
    end

    def end_paragraph
      return if @paragraph.empty?

      if @paragraph.size == 1
        last = @paragraph.pop
        split_paragraph_end_event(last) { |e| yield e }
        return
      end

      last = @paragraph.pop
      @paragraph.each { |p| yield p }
      @paragraph.clear
      split_paragraph_end_event(last) { |e| yield e }
    end

    def split_paragraph_end_event(e)
      newline = e.source[/ *\R\z/]
      yield e.class.new(e.lineno, e.source[0...e.source.size-newline.size])
      yield ParagraphEndEvent.new(e.lineno, newline)
    end

    def parse_blank_lines(input)
      line, lineno = input.next
      yield BlankLinesStartEvent.new(lineno, '')
      yield BlankLinesInlineContentEvent.new(lineno, line)
      loop do
        line, lineno = input.peek
        break unless line.match(/^ *$/)
        line, lineno = input.next
        yield BlankLinesInlineContentEvent.new(lineno, line)
      end
      yield BlankLinesEndEvent.new(lineno, '')
    end

    def parse_blockquote(input)
      line, lineno = input.peek
      yield BlockQuoteStartEvent.new(lineno, '')
      original = {}
      new_input = Enumerator.new do |y|
        loop do
          line, lineno = input.peek
          raise StopIteration if line.match(/^ *$/)
          line, lineno = input.next
          original[lineno] = line
          y << [line.gsub(/^ {0,3}> ?/, ''), lineno]
        end
      end

      self.class.new(new_input).each do |e|
        yield BlockQuoteInlineContentEvent.new(e.lineno, original.fetch(e.lineno), child: e)
      end
      yield BlockQuoteEndEvent.new(original.keys.max, '')
    end

    def parse_fenced_code(input)
      FencedCodeParser.parse(input) { |event| yield event }
    end

    def parse_indented_code(input)
      line, lineno = input.next
      yield IndentedCodeStartEvent.new(lineno, '')
      yield IndentedCodeInlineContentEvent.new(lineno, line)
      loop do
        line, lineno = input.peek
        case line
        when /^ {4,}/
          line, lineno = input.next
          yield IndentedCodeInlineContentEvent.new(lineno, line)
        when /^ *$/
          line, lineno = input.next
          yield IndentedCodeInlineContentEvent.new(lineno, line)
        else
          raise StopIteration
        end
      end
      yield IndentedCodeEndEvent.new(lineno, '')
    end

    def parse_atx_heading(input)
      AtxHeadingParser.parse(input) {|ah| yield ah }
    end

    def parse_thematic_break(input)
      line, lineno = input.next
      yield ThematicBreakStartEvent.new(lineno, line)
      yield ThematicBreakEndEvent.new(lineno, '')
    end

    def parse_unordered_list(input)
      UnorderedListParser.parse(input, @list_level) {|li| yield li }
    end
  end
end
