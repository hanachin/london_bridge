module LondonBridge
  class BlockParser
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
      n = klass.name.split('::').last
      %w(ThematicBreak AtxHeading FencedCode IndentedCode BlankLines Paragraph BlockQuote UnOrderedList ListItem).each do |b|
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
  end
end
