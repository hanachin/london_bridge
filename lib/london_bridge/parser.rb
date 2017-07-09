module LondonBridge
  class Parser
    # @param tokens [Array<Token>] the tokens of markdown
    # @return [Array] the AST of the markdown
    def parse(tokens)
      ast = []
      tokens.each_with_index do |t, i|
        case t
        when HeaderToken
          ast << [t, tokens.delete_at(i + 1)]
        when TextToken
          ast << [t]
        end
      end
      ast
    end
  end
end
