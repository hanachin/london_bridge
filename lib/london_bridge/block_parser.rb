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
      %w(ThematicBreak AtxHeading FencedCode IndentedCode BlankLines Paragraph).each do |b|
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

    def each
      input = self.input.each.with_index
      loop do
        line, lineno = input.next
        case line
        when /^ {0,3}(\*|-|_)(?: *\1 *){2,}$/
          end_paragraph { |p| yield p }
          yield ThematicBreakStartEvent.new(lineno, line)
          yield ThematicBreakEndEvent.new(lineno, '')
        when /^( {0,3}\#{1,6} +)((?:.(?! +#+ *\R| +\R))*.)((?: +#+ *| *)?\R)/
          end_paragraph { |p| yield p }
          yield AtxHeadingStartEvent.new(lineno, $~[1])
          yield AtxHeadingInlineContentEvent.new(lineno, $~[2])
          yield AtxHeadingEndEvent.new(lineno, $~[3])
        when /^( {0,3})((`|~)\3{2,})(?:\R| +\R| +((?:.(?! +\R))+.) *\R)/
          end_paragraph { |p| yield p }
          options = { indent: $~[1].size, fence: $~[3], fence_length: $~[2].size, info_string: $~[4] }
          yield FencedCodeStartEvent.new(lineno, line, **options)
          parse_fenced_code(input, **options) { |event| yield event }
        when /^ {4,}[^ \n\r]/
          end_paragraph { |p| yield p }
          yield IndentedCodeStartEvent.new(lineno, '')
          yield IndentedCodeInlineContentEvent.new(lineno, line)
          parse_indented_code(input) { |event| yield event }
        when /^ *$/
          end_paragraph { |p| yield p }
          yield BlankLinesStartEvent.new(lineno, '')
          yield BlankLinesInlineContentEvent.new(lineno, line)
          parse_blank_lines(input) { |event| yield event }
          yield BlankLinesEndEvent.new(lineno, '')
        else
          add_paragraph(lineno, line)
        end
      end
    end

    private

    def add_paragraph(lineno, source)
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
      loop do
        line, lineno = input.peek
        break unless line.match(/^ *$/)
        line, lineno = input.next
        yield BlankLinesInlineContentEvent.new(lineno, line)
      end
    end

    def parse_fenced_code(input, indent:, fence:, fence_length:, **)
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
  end
end
