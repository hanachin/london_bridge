module LondonBridge
  class BlockParser
    module Detab
      refine(String) do
        def tab_width
          4
        end

        def detab
          return self if size.zero?

          sub(/\A\t+/) { |tabs| " " * (tabs.size * tab_width) }.
            sub(/\A( +)(\t+)/) { $1 + " " * ((tab_width - $1.size % tab_width) + ($2.size - 1)) }.
            sub(/\A([\-#>])(\t+)/) { $1 + " " * (3 + ($2.size - 1) * tab_width) }
        end
      end
    end
  end
end
