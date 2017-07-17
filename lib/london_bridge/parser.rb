module LondonBridge
  class Parser
    module Buffer
      refine(Array) do
        alias peek_n []
        alias peek first
        alias next_token shift
        alias push_token unshift
      end
    end

    using Buffer

    # @param tokens [Array<Token>] the tokens of markdown
    # @return [Array] the AST of the markdown
    def parse(tokens)
      buffer = tokens.dup
      ast = [:root]
      loop do
        break unless buffer.peek

        case buffer.peek
        when HeaderToken
          t = buffer.next_token
          inline_content = []
          while buffer.peek.is_a?(TextToken)
            inline_content << buffer.next_token
          end
          ast << [:header, t, [[:text, inline_content]]]
        when IndentToken
          content = []
          catch(:end_block) do
            while buffer.peek&.is_a?(IndentToken)
              buffer.next_token
              content << buffer.next_token until buffer.peek.nil? || buffer.peek.is_a?(NewlineToken)
              throw(:end_block) unless buffer.peek

              content << buffer.next_token

              unless buffer.peek.is_a?(IndentToken)
                buffer.next_token while buffer.peek.is_a?(NewlineToken)
                throw(:end_block)
              end
            end
          end
          ast << [:codeblock, [:code, content]]
        when BlockquoteToken
          ts = []
          catch(:eof) do
            loop do
              while buffer.peek.is_a?(BlockquoteToken)
                buffer.next_token
                ts << buffer.next_token until buffer.peek.nil? || buffer.peek.is_a?(NewlineToken)
                throw(:eof) if buffer.peek.nil?

                ts << buffer.next_token
              end

              if buffer.peek.is_a?(TextToken)
                ts << buffer.next_token while buffer.peek.is_a?(TextToken)
                ts << buffer.next_token if buffer.peek.is_a?(NewlineToken)
                next
              end

              throw(:eof)
            end
          end
          ts.pop if ts.last.is_a?(NewlineToken)
          content = parse(ts)
          _root, *children = content
          ast << [:blockquote, children]
        when TextToken
          ast << parse_paragraph(buffer)
        when ThematicBreakToken
          buffer.next_token
          ast << [:hr]
        else
          buffer.next_token
        end
      end
      ast
    end

    private

    def parse_paragraph(buffer)
      content = []
      loop do
        case buffer.peek
        when SpecialToken
          t = buffer.next_token
          # TODO support more special tokens
          unless t.source == "`"
            buffer.push_token(TextToken.new(t.source))
            next
          end

          index = 0
          loop do
            break unless buffer[index]
            break unless buffer[index].is_a?(TextToken)
            index += 1
            break if buffer[index].source == t.source
          end

          if index.zero? || buffer[index].nil? || buffer[index].source != t.source
            buffer.push_token(TextToken.new(t.source))
            next
          end

          # TODO support nested special tokens
          code = buffer[0...index]
          content << [:code, code]
          (0..index).each do
            buffer.next_token
          end
        when TextToken
          text = [buffer.next_token]
          loop do
            break unless buffer.peek

            if buffer.peek.is_a?(TextToken) && !buffer.peek.is_a?(SpecialToken)
              text << buffer.next_token
              next
            end

            if buffer.peek.is_a?(NewlineToken) && !buffer.peek_n(1).is_a?(NewlineToken)
              text << buffer.next_token
              next
            end

            break
          end
          content << [:text, text]
        else
          return [:paragraph, *content]
        end
      end
    end
  end
end
