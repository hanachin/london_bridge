module LondonBridge
  class Renderer < Struct.new(:parser, :output)
    class Context < Struct.new(:renderer, :blocks, :indented_codes_maybe)
      def print(s)
        renderer.output.print(s)
      end

      def puts(s)
        renderer.output.puts(s)
      end

      def current_block
        blocks.last
      end

      def current_list_block
        blocks.reverse_each.detect { |b| b.kind_of?(LondonBridge::BlockParser::ListItemStartEvent) }
      end

      def previous_list_block
        blocks.reverse_each.map { |b| b.kind_of?(LondonBridge::BlockParser::ListItemStartEvent) }.drop(1).first
      end
    end

    private

    def current_context
      @context
    end

    def reset_context
      @context = Context.new(self, [], [])
    end
  end
end
