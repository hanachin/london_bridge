module LondonBridge
  class HtmlRenderer
    # @return [String] the HTML of markdown
    # @param ast [Array] the AST of markdown
    def render(ast)
      md = ""
      ast.each do |n|
        md << public_send("on_#{n.name}", n)
      end
      md
    end

    # @param t [TextToken] the token of the text
    # @return [String] the text
    def on_text(t)
      t.text
    end
  end
end
