module LondonBridge
  class HtmlRenderer
    # @return [String] the HTML of markdown
    # @param ast [Array] the AST of markdown
    def render(ast)
      md = ""
      ast.each do |(n,*rest)|
        md << public_send("on_#{n.name}", n, rest)
      end
      md
    end

    # @param t [TextToken] the token of the text
    # @return [String] the text
    def on_text(t, _)
      t.text
    end

    # @param t [HeaderToken] the token of header
    # @return [String] the text
    def on_header(t, rest)
      tag = "h#{t.level}"
      "<#{tag}>#{render(rest)}</#{tag}>"
    end
  end
end
