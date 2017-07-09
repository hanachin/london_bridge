module LondonBridge
  class Parser
    # @param tokens [Array<Token>] the tokens of markdown
    # @return [Array] the AST of the markdown
    def parse(tokens)
      tokens = tokens.dup
      ast = [:root]
      tokens.each_with_index do |t, i|
        case t
        when HeaderToken
          inline_content = []
          while tokens.size.nonzero? && tokens[i + 1].is_a?(TextToken)
            inline_content << tokens.delete_at(i + 1)
          end
          ast << [:header, t, [[:text, inline_content]]]
        when TextToken
          content = [t]
          loop do
            break if tokens[i + 1].nil?

            if tokens[i + 1].is_a?(TextToken)
              content << tokens.delete_at(i + 1)
              next
            end

            if tokens[i + 1].is_a?(NewlineToken) && !tokens[i + 2].is_a?(NewlineToken)
              content << tokens.delete_at(i + 1)
              next
            end

            break
          end
          ast << [:paragraph, [:text, content]]
        when ThematicBreakToken
          ast << [:hr]
        end
      end
      ast
    end
  end
end
