require_relative "token"
require_relative "newline_token"
require_relative "backslash_escaped_token"

module LondonBridge
  class TextToken < Token
    alias text source

    PUNCTUATION = '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'

    def self.scanner
      lambda do |md, &blk|
        return unless m = md.match(/\A(.+$)(\R)?/)

        t = ""
        cs = m[1].chars
        cs.each_with_index do |c, i|
          case c
          when "\\"
            if cs[i + 1] && PUNCTUATION.index(cs[i + 1])
              blk&.call(TextToken.new(t)) unless t.empty?
              blk&.call(BackslashEscapedToken.new(c + cs.delete_at(i + 1)))
              t = ""
            else
              t << c
            end
          else
            t << c
          end
        end
        blk&.call(TextToken.new(t)) unless t.empty?
        blk&.call(NewlineToken.new(m[2])) if m[2]
        md[m[0].size..-1]
      end
    end
  end
end
