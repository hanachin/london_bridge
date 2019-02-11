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
      %w(ThematicBreak AtxHeading FencedCode IndentedCode BlankLines Paragraph BlockQuote UnOrderedList ListItem).each do |b|
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


    [ListItemStartEvent, ListItemEndEvent].each do |klass|
      klass.class_eval do
        def list_indent
          @options.fetch(:list_indent)
        end

        def tight?
          @options.fetch(:tight, false)
        end
      end
    end

    ListItemInlineContentEvent.class_eval do
      def child
        @options.fetch(:child)
      end

      def tight?
        @options.fetch(:tight, false)
      end
    end

    def each
      input = self.input.each.with_index
      last_lineno = 0
      @ul_continue = false
      loop do
        line, lineno = input.peek
        @last_lineno = lineno
        ul_hit = false
        case line
        when /^ {0,3}(\*|-|_)(?:[\t ]*\1[\t ]*){2,}$/
          end_ul {|e| yield  e }
          end_paragraph { |p| yield  p }
          parse_thematic_break(input) { |tb| yield tb }
        when /^( {0,3}\#{1,6}(?!#)(?:[ \t]+|(?=\R)))(?:|(#+[ \t]*)|(.*)([ \t]+#+[ \t]*)|(.*))\R/
          end_ul {|e| yield  e }
          end_paragraph { |p| yield p }
          parse_atx_heading(input, $~) { |h| yield h }
        when /^( {0,3})((`|~)\3{2,})(?:\R| +\R| +((?:.(?! +\R))+.) *\R)/
          end_ul {|e| yield  e }
          end_paragraph { |p| yield p }
          options = { indent: $~[1].size, fence: $~[3], fence_length: $~[2].size, info_string: $~[4] }
          parse_fenced_code(input, **options) { |event| yield event }
        when /^( {4,}| *\t)[^ \n\r]/
          end_ul {|e| yield  e }
          end_paragraph { |p| yield p }
          parse_indented_code(input) { |event| yield event }
        when /^ *$/
          end_ul {|e| yield  e }
          end_paragraph { |p| yield p }
          parse_blank_lines(input) { |event| yield event }
        when /^ {0,3}> ?/
          end_ul {|e| yield  e }
          end_paragraph { |p| yield p }
          parse_blockquote(input) { |event| yield event }
        when /^( {0,3}(?:-|\+|\*)[ \t]+)/
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
      @paragraph ||= []
      if @paragraph.empty?
        @paragraph << ParagraphStartEvent.new(lineno, '')
        @paragraph << ParagraphInlineContentEvent.new(lineno, source)
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
        when /^( {4}|\t)/
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

      indent_tabable, indent_sp = indent.divmod(4)
      if indent_tabable.zero?
        regexp = /^ {#{indent}}/
      else
        if indent_sp.zero?
          regexp = /^(?: {#{indent}}|\t{#{indent_tabable}})/
        else
          regexp = /^(?: {#{indent}}| {#{indent_sp}}\t{#{indent_tabable}})/
        end
      end

      offset = lineno
      original = {}
      new_input = Enumerator.new do |y|
        original[lineno] = line
        y << line[indent..-1]
        loop do
          line, lineno = input.peek
          if !line.match(regexp) && !line.match(/^\s*$/)
            raise StopIteration
          end
          line, lineno = input.next
          original[lineno] = line
          y << line.sub(regexp, '')
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
      tight = children2.map(&:source).compact.join.count("\n") <= 1
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
