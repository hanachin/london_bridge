module LondonBridge
  class Parser
    # @param tokens [Array<Token>] the tokens of markdown
    # @return [Array] the AST of the markdown
    def parse(tokens)
      ast = [:root]
      tokens.each_with_index do |t, i|
        case t
        when HeaderToken
          ast << [:header, t, [[:text, tokens.delete_at(i + 1)]]]
        when TextToken
          ast << [:paragraph, [:text, t]]
        end
      end
      ast
    end
  end
end
