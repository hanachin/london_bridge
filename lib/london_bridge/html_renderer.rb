require_relative 'renderer'
require_relative 'render_html'

module LondonBridge
  class HtmlRenderer < Renderer
    using RenderHtml

    def render
      reset_context
      parser.each do |event|
        handle_event(event)
      end
    end

    private

    def handle_event(event)
      case event
      when LondonBridge::BlockParser::StartEvent
        current_context.blocks << event
        event.render(current_context)
      when LondonBridge::BlockParser::EndEvent
        event.render(current_context)
        current_context.blocks.pop
      when LondonBridge::BlockParser::InlineContentEvent
        event.render(current_context)
      end
    end
  end
end
