module LondonBridge
  class HtmlRenderer
    # @return [String] the HTML of markdown
    # @param ast [Array] the AST of markdown
    def render(ast)
      md = ""
      n, *rest = ast
      md << public_send("on_#{n}", *rest)
      md
    end

    # @param children [Array] the ast of markdown document
    # @return [String] rendered HTML
    def on_root(*children)
      children.map { |a| render(a) }.join("\n")
    end

    # @param ts [Array<TextToken>] the token of the text
    # @return [String] the text
    def on_text(ts)
      ts.map(&:text).join
    end

    # @param children [Array] the ast of the content
    # @return [String] the paragraph
    def on_paragraph(*children)
      content = children.map { |c| render(c) }.join
      "<p>#{content}</p>"
    end

    # @param t [HeaderToken] the token of header
    # @return [String] the text
    def on_header(h, children)
      tag = "h#{h.level}"
      content = children.map { |c| render(c) }.join
      "<#{tag}>#{content}</#{tag}>"
    end

    # @return [String] the hr
    def on_hr
      "<hr />"
    end
  end
end
