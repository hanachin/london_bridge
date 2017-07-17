module LondonBridge
  class Parser
    # @param tokens [Array<Token>] the tokens of markdown
    # @return [Array] the AST of the markdown
    def parse(tokens)
      buffer = tokens.dup
      ast = [:root]
      buffer.each_with_index do |t, i|
        case t
        when HeaderToken
          inline_content = []
          while buffer.size.nonzero? && buffer[i + 1].is_a?(TextToken)
            inline_content << buffer.delete_at(i + 1)
          end
          ast << [:header, t, [[:text, inline_content]]]
        when IndentToken
          content = []
          content << buffer.delete_at(i + 1) until buffer[i + 1].nil? || buffer[i + 1].is_a?(NewlineToken)
          content << buffer.delete_at(i + 1) unless buffer[i + 1].nil?
          catch(:end_block) do
            while !buffer.empty? && buffer[i + 1].is_a?(IndentToken)
              buffer.delete_at(i + 1)
              content << buffer.delete_at(i + 1) until buffer[i + 1].nil? || buffer[i + 1].is_a?(NewlineToken)
              throw(:end_block) if buffer[i + 1].nil?

              content << buffer.delete_at(i + 1)

              unless buffer[i + 1].is_a?(IndentToken)
                buffer.delete_at(i + 1) while buffer[i + 1].is_a?(NewlineToken)
                throw(:end_block)
              end
            end
          end
          ast << [:codeblock, [:code, content]]
        when BlockquoteToken
          ts = []
          catch(:eof) do
            loop do
              while buffer.size > i && buffer[i].is_a?(BlockquoteToken)
                buffer.delete_at(i)
                ts << buffer.delete_at(i) until buffer[i].nil? || buffer[i].is_a?(NewlineToken)
                throw(:eof) if buffer[i].nil?

                ts << buffer.delete_at(i)
              end

              if buffer[i].is_a?(TextToken)
                ts << buffer.delete_at(i) while buffer[i].is_a?(TextToken)
                ts << buffer.delete_at(i) if buffer[i].is_a?(NewlineToken)
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
            buffer.insert(i + 1, TextToken.new(t.source))
            next
          end

          index = i
          loop do
            break unless buffer[index + 1]
            break unless buffer[index + 1].is_a?(TextToken)
            index += 1
            break if buffer[index].source == t.source
          end

          if index == i || buffer[index].nil? || buffer[index].source != t.source
            buffer.insert(i + 1, TextToken.new(t.source))
            next
          end

          # TODO support nested special tokens
          code = buffer[i+1...index]
          ast << [:code, code]
          (index - i + 1).times do
            buffer.delete_at(i + 1)
          end
        when TextToken
          content = [t]
          loop do
            break if buffer[i + 1].nil?

            if buffer[i + 1].is_a?(TextToken)
              content << buffer.delete_at(i + 1)
              next
            end

            if buffer[i + 1].is_a?(NewlineToken) && !buffer[i + 2].is_a?(NewlineToken)
              content << buffer.delete_at(i + 1)
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
