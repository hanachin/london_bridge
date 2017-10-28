require_relative 'block_parser'

module LondonBridge
  module RenderHtml
    refine(LondonBridge::BlockParser::StartEvent) do
      def render(_)
      end
    end

    refine(LondonBridge::BlockParser::EndEvent) do
      def render(_)
      end
    end

    refine(LondonBridge::BlockParser::InlineContentEvent) do
      def render(ctx)
        ctx.print source
      end
    end

    refine(LondonBridge::BlockParser::ThematicBreakStartEvent) do
      def render(ctx)
        ctx.puts '<hr />'
      end
    end

    refine(LondonBridge::BlockParser::AtxHeadingStartEvent) do
      def render(ctx)
        ctx.print "<h#{depth}>"
      end
    end

    refine(LondonBridge::BlockParser::AtxHeadingEndEvent) do
      def render(ctx)
        ctx.puts "</h#{ctx.current_block.depth}>"
      end
    end

    refine(LondonBridge::BlockParser::FencedCodeStartEvent) do
      def render(ctx)
        if l = language
          ctx.print %(<pre><code class="language-#{l}">)
        else
          ctx.print '<pre><code>'
        end
      end
    end

    refine(LondonBridge::BlockParser::FencedCodeEndEvent) do
      def render(ctx)
        ctx.puts '</code></pre>'
      end
    end

    refine(LondonBridge::BlockParser::FencedCodeInlineContentEvent) do
      def render(ctx)
        if indent.zero?
          ctx.print source
        else
          prefix = source[/^ {0,#{indent}}/]
          ctx.print source[prefix.size..-1]
        end
      end
    end

    refine(LondonBridge::BlockParser::IndentedCodeStartEvent) do
      def render(ctx)
        ctx.print '<pre><code>'
      end
    end

    refine(LondonBridge::BlockParser::IndentedCodeEndEvent) do
      def render(ctx)
        ctx.indented_codes_maybe&.clear
        ctx.puts '</code></pre>'
      end
    end

    refine(LondonBridge::BlockParser::IndentedCodeInlineContentEvent) do
      def render(ctx)
        if blank_line?
          ctx.indented_codes_maybe << self
        else
          ctx.indented_codes_maybe.each do |code|
            ctx.print code.source[4..-1]
          end
          ctx.indented_codes_maybe.clear
          ctx.puts source[4..-1]
        end
      end
    end

    refine(LondonBridge::BlockParser::BlankLinesInlineContentEvent) do
      def render(_)
        # ignore
      end
    end

    refine(LondonBridge::BlockParser::ParagraphStartEvent) do
      def render(ctx)
        ctx.print('<p>')
        start = source[/\A */].size
        ctx.print(source[start..-1])
      end
    end

    refine(LondonBridge::BlockParser::ParagraphEndEvent) do
      def render(ctx)
        ctx.puts('</p>')
      end
    end

    refine(LondonBridge::BlockParser::BlockQuoteStartEvent) do
      def render(ctx)
        ctx.puts('<blockquote>')
      end
    end

    refine(LondonBridge::BlockParser::BlockQuoteInlineContentEvent) do
      def render(ctx)
        case child
        when LondonBridge::BlockParser::StartEvent
          ctx.blocks << child
          child.render(ctx)
        when LondonBridge::BlockParser::EndEvent
          child.render(ctx)
          ctx.blocks.pop
        when LondonBridge::BlockParser::InlineContentEvent
          child.render(ctx)
        end
      end
    end

    refine(LondonBridge::BlockParser::BlockQuoteEndEvent) do
      def render(ctx)
        ctx.puts('</blockquote>')
      end
    end

    refine(LondonBridge::BlockParser::UnOrderedListStartEvent) do
      def render(ctx)
        ctx.puts('<ul>')
      end
    end

    refine(LondonBridge::BlockParser::UnOrderedListEndEvent) do
      def render(ctx)
        ctx.puts('</ul>')
      end
    end

    refine(LondonBridge::BlockParser::ListItemStartEvent) do
      def render(ctx)
        if tight?
          ctx.print('<li>')
        else
          ctx.puts('<li>')
        end
      end
    end

    refine(LondonBridge::BlockParser::ListItemInlineContentEvent) do
      def render(ctx)
        case child
        when LondonBridge::BlockParser::StartEvent
          return if ctx.current_list_block.tight? && child.kind_of?(LondonBridge::BlockParser::ParagraphStartEvent)
          ctx.blocks << child
          child.render(ctx)
        when LondonBridge::BlockParser::EndEvent
          return if ctx.current_list_block.tight? && child.kind_of?(LondonBridge::BlockParser::ParagraphEndEvent)
          child.render(ctx)
          ctx.blocks.pop
        when LondonBridge::BlockParser::InlineContentEvent
          child.render(ctx)
        end
      end
    end

    refine(LondonBridge::BlockParser::ListItemEndEvent) do
      def render(ctx)
        ctx.puts('</li>')
      end
    end
  end
end
