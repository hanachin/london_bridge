module LondonBridge
  class BlockParser
    module FencedCodeHelper
      refine(String) do
        using ::LondonBridge::BlockParser::Markers

        def closing_code_fence
          raise ::LondonBridge::Error unless fenced_code_block?

          match(/^ *([~`]+) *$/)&.then { |m| m[1] }
        end

        def closing_code_fence_of?(opening_code_fence)
          closing_code_fence&.start_with?(opening_code_fence)
        end

        def code_fence_indentation
          raise ::LondonBridge::Error unless fenced_code_block?

          match(/^( *)/)[1].size
        end

        def code_fence_info_string
          raise ::LondonBridge::Error unless fenced_code_block?

          info_string = match(/^ *[~`]+(.*)$/)[1].strip
          info_string unless info_string.empty?
        end

        def opening_code_fence
          raise ::LondonBridge::Error unless fenced_code_block?

          match(/^ *([~`]+)/)[1]
        end
      end
    end
  end
end
