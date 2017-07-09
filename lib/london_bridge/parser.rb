module LondonBridge
  class Parser
    # @param tokens [Array<Token>] the tokens of markdown
    # @return [Array] the AST of the markdown
    def parse(tokens)
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
          ast << [:paragraph, [:text, [t]]]
        when ThematicBreakToken
          ast << [:hr]
        end
      end
      ast
    end
  end
end
