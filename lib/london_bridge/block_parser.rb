require_relative 'block_parser/detab'
require_relative 'block_parser/events'
require_relative 'block_parser/markers'
require_relative 'block_parser/fenced_code_parser'

module LondonBridge
  class BlockParser
    include Enumerable

    using Detab
    using FencedCodeHelper
    using Markers

    def initialize(input)
      @input = input
      @paragraph = []
    end

    def each
      input = @input.each.with_index

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
          parse_atx_heading(input, $~) { |h| yield h }
        when line.fenced_code_block?
          end_ul {|e| yield  e }
          end_paragraph { |p| yield p }
          options = { indent: $~[1].size, fence: $~[3], fence_length: $~[2].size, info_string: $~[4] }
          parse_fenced_code(input, **options) { |event| yield event }
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
          parse_unordered_list(input, indent: $~[1].size) { |event| yield event }
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
      offset = lineno
      original = {}
      new_input = Enumerator.new do |y|
        loop do
          line, lineno = input.peek
          raise StopIteration if line.match(/^ *$/)
          line, lineno = input.next
          original[lineno] = line
          y << line.gsub(/^ {0,3}> ?/, '')
        end
      end

      self.class.new(new_input).each do |e|
        yield BlockQuoteInlineContentEvent.new(e.lineno + offset, original.fetch(e.lineno + offset), child: e)
      end
      yield BlockQuoteEndEvent.new(original.keys.max, '')
    end

    def parse_fenced_code(input)
      line, lineno = input.next
      indent = line.code_fence_indentation
      info_string = line.code_fence_info_string
      opening_code_fence = line.opening_code_fence
      yield FencedCodeStartEvent.new(lineno, line, indent: indent, info_string: info_string)
      loop do
        line, lineno = input.next
        case
        when line.closing_code_fence_of?(opening_code_fence) 
          yield FencedCodeEndEvent.new(lineno, line)
          break
        else
          yield FencedCodeInlineContentEvent.new(lineno, line, indent: indent)
        end
      end
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

    def parse_atx_heading(input, m)
      line, lineno = input.next
      yield AtxHeadingStartEvent.new(lineno, m[1])
      yield AtxHeadingInlineContentEvent.new(lineno, m[3] || m[5])
      yield AtxHeadingEndEvent.new(lineno, m[2] || m[4] || '')
    end

    def parse_thematic_break(input)
      line, lineno = input.next
      yield ThematicBreakStartEvent.new(lineno, line)
      yield ThematicBreakEndEvent.new(lineno, '')
    end

    def list_indent
      store[:list_indent] ||= 0
    end

    def inc_list_indent
      store[:list_indent] = list_indent + 1
    end

    def dec_list_indent
      store[:list_indent] = list_indent - 1
    end

    def store
      Thread.current[:london_bridge_store] ||= {}
    end

    def parse_unordered_list(input, indent:)
      line, lineno = input.next
      inc_list_indent

      start_event = ListItemStartEvent.new(lineno, line, list_indent: list_indent)

      offset = lineno
      original = {}
      new_input = Enumerator.new do |y|
        original[lineno] = line
        y << line[indent..-1]
        loop do
          line, lineno = input.peek
          if !line.match(/^ {#{indent}}/) && !line.match(/^\s*$/)
            raise StopIteration
          end
          line, lineno = input.next
          original[lineno] = line
          y << line.sub(/ {#{indent}}/, '')
        end
      end

      children = self.class.new(new_input).map do |e|
        ListItemInlineContentEvent.new(e.lineno + offset, original.fetch(e.lineno + offset), child: e)
      end

      end_event = ListItemEndEvent.new(lineno, line, list_indent: list_indent)

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

      yield start_event
      children.each { |child| yield child }
      yield end_event

      dec_list_indent
    end
  end
end
