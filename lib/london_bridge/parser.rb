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
        when IndentToken
          content = []
          content << tokens.delete_at(i + 1) until tokens[i + 1].nil? || tokens[i + 1].is_a?(NewlineToken)
          content << tokens.delete_at(i + 1) unless tokens[i + 1].nil?
          catch(:end_block) do
            while !tokens.empty? && tokens[i + 1].is_a?(IndentToken)
              tokens.delete_at(i + 1)
              content << tokens.delete_at(i + 1) until tokens[i + 1].nil? || tokens[i + 1].is_a?(NewlineToken)
              throw(:end_block) if tokens[i + 1].nil?

              content << tokens.delete_at(i + 1)

              unless tokens[i + 1].is_a?(IndentToken)
                tokens.delete_at(i + 1) while tokens[i + 1].is_a?(NewlineToken)
                throw(:end_block)
              end
            end
          end
          ast << [:codeblock, [:code, content]]
        when BlockquoteToken
          ts = []
          catch(:eof) do
            loop do
              while tokens.size > i && tokens[i].is_a?(BlockquoteToken)
                tokens.delete_at(i)
                ts << tokens.delete_at(i) until tokens[i].nil? || tokens[i].is_a?(NewlineToken)
                throw(:eof) if tokens[i].nil?

                ts << tokens.delete_at(i)
              end

              if tokens[i].is_a?(TextToken)
                ts << tokens.delete_at(i) while tokens[i].is_a?(TextToken)
                ts << tokens.delete_at(i) if tokens[i].is_a?(NewlineToken)
                next
              end

              throw(:eof)
            end
          end
          ts.pop if ts.last.is_a?(NewlineToken)
          content = parse(ts)
          _root, *children = content
          ast << [:blockquote, children]
        when SpecialToken
          # TODO support more special tokens
          unless t.source == "`"
            tokens.insert(i + 1, TextToken.new(t.source))
            next
          end

          index = i
          loop do
            break unless tokens[index + 1]
            break unless tokens[index + 1].is_a?(TextToken)
            index += 1
            break if tokens[index].source == t.source
          end

          if index == i || tokens[index].nil? || tokens[index].source != t.source
            tokens.insert(i + 1, TextToken.new(t.source))
            next
          end

          # TODO support nested special tokens
          code = tokens[i+1...index]
          ast << [:code, code]
          (index - i + 1).times do
            tokens.delete_at(i + 1)
          end
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
