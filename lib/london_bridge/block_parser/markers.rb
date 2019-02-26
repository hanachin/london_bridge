module LondonBridge
  class BlockParser
    module Markers
      refine(String) do
        def atx_heading?
          match?(/^ {0,3}\#{1,6} */)
        end

        def blank_line?
          match?(/^ *$/)
        end

        def block_quotes?
          match?(/^ {0,3}> ?/)
        end

        def bullet_list?
          match?(/^ {0,3}(?:-|\+|\*)(?:$|(?: |  |   (?! ))(?!-|\+|\*))/)
        end

        def fenced_code_block?
          match?(/^ {0,3}(?:(`|~)\1{2,})(?: *[^`~]+)* *$/)
        end

        def indented_code_block?
          match?(/^ {4,}/)
        end

        def thematic_break?
          match?(/^ {0,3}(\*|-|_)(?:[\t ]*\1[\t ]*){2,}$/)
        end
      end
    end
  end
end
