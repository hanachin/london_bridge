require_relative 'fenced_code_helper'

module LondonBridge
  class BlockParser
    class FencedCodeParser
      using FencedCodeHelper

      def initialize(start_line)
        @opening_code_fence = start_line.opening_code_fence
      end
    end
  end
end
