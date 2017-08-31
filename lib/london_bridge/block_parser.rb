module LondonBridge
  class BlockParser < Struct.new(:input)
    class Event < Struct.new(:lineno, :source)
      attr_accessor :options

      def initialize(*args, **options)
        super(*args)
        @options = options
      end
    end
    class StartEvent < Event; end
    class EndEvent < Event; end
    class InlineContentEvent < Event
      def blank_line?
        source.match(/^ *$/)
      end
    end

    [StartEvent, EndEvent, InlineContentEvent].each do |klass|
      %w(ThematicBreak AtxHeading FencedCode IndentedCode BlankLines Paragraph BlockQuote).each do |b|
        n = klass.name.split('::').last
        const_set("#{b}#{n}", Class.new(klass))
      end
    end

    AtxHeadingStartEvent.class_eval do
      def depth
        source.count(?#)
      end
    end

    FencedCodeStartEvent.class_eval do
      def info_string
        @options.fetch(:info_string)
      end

      def language
        info_string&.split(' ', 2)&.first
      end
    end

    FencedCodeInlineContentEvent.class_eval do
      def indent
        @options.fetch(:indent)
      end
    end

    FencedCodeInlineContentEvent.class_eval do
      def indent
        @options.fetch(:indent)
      end
    end

    BlockQuoteInlineContentEvent.class_eval do
      def child
        @options.fetch(:child)
      end
    end

    def each
      input = self.input.each.with_index
      loop do
        line, lineno = input.peek
        case line
        when /^ {0,3}(\*|-|_)(?: *\1 *){2,}$/
          end_paragraph { |p| yield p }
          parse_thematic_break(input) { |tb| yield tb }
        when /^( {0,3}\#{1,6} +)(?:|#+ *|(.*)(?: +#+ *)|(.*))\R/
          end_paragraph { |p| yield p }
          parse_atx_heading(input, $~) { |h| yield h }
        when /^( {0,3})((`|~)\3{2,})(?:\R| +\R| +((?:.(?! +\R))+.) *\R)/
          end_paragraph { |p| yield p }
          options = { indent: $~[1].size, fence: $~[3], fence_length: $~[2].size, info_string: $~[4] }
          parse_fenced_code(input, **options) { |event| yield event }
        when /^ {4,}[^ \n\r]/
          end_paragraph { |p| yield p }
          parse_indented_code(input) { |event| yield event }
        when /^ *$/
          end_paragraph { |p| yield p }
          parse_blank_lines(input) { |event| yield event }
        when /^ {0,3}> ?/
          end_paragraph { |p| yield p }
          parse_blockquote(input) { |event| yield event }
        else
          add_paragraph(input)
        end
      end
      end_paragraph { |p| yield p }
    end

    private

    def add_paragraph(input)
      source, lineno = input.next
      @paragraph ||= []
      if @paragraph.empty?
        @paragraph << ParagraphStartEvent.new(lineno, source)
      else
        @paragraph << ParagraphInlineContentEvent.new(lineno, source)
      end
    end

    def end_paragraph
      return if @paragraph.nil? || @paragraph.empty?

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

    def parse_fenced_code(input, indent:, fence:, fence_length:, info_string:)
      line, lineno = input.next
      yield FencedCodeStartEvent.new(lineno, line, indent: indent, fence: fence, fence_length: fence_length, info_string: info_string)

      code_fence = /^ {0,3}#{fence}{#{fence_length},}\R/
      loop do
        line, lineno = input.next
        case line
        when code_fence
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
        when /^ {4,}[^ \R]/
          line, lineno = input.next
          yield IndentedCodeInlineContentEvent.new(lineno, line)
        when /^ *$/
          line, lineno = input.next
          yield IndentedCodeInlineContentEvent.new(lineno, line)
        else
          yield IndentedCodeEndEvent.new(lineno, '')
          break
        end
      end
    end

    def parse_atx_heading(input, m)
      line, lineno = input.next
      yield AtxHeadingStartEvent.new(lineno, m[1])
      yield AtxHeadingInlineContentEvent.new(lineno, m[2] || m[4])
      yield AtxHeadingEndEvent.new(lineno, m[3] || '')
    end

    def parse_thematic_break(input)
      line, lineno = input.next
      yield ThematicBreakStartEvent.new(lineno, line)
      yield ThematicBreakEndEvent.new(lineno, '')
    end
  end
end
