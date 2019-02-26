# examples from CommonMark Spec 0.28
RSpec.describe LondonBridge::BlockParser::Markers do
  describe '#atx_heading?' do
    specify do
      markers = [
        "# foo",
        "## foo",
        "### foo",
        "#### foo",
        "##### foo",
        "###### foo",
        "#                  foo                     ",
        " ### foo",
        "  ## foo",
        "   # foo",
        "## foo ##",
        "  ###   bar    ###",
        "# foo ##################################",
        "##### foo ##",
        "### foo ###     ",
        "### foo ### b",
        "# foo#",
        "### foo \###",
        "## foo #\##",
        "# foo \#",
        "## ",
        "#",
        "### ###"
      ]
      expect(markers).to all(be_marked_as(:atx_heading))
    end

    specify do
      aggregate_failures do
        expect("###### foo").not_to be_marked_as(:thematic_break)
        expect("#5 bolt").not_to be_marked_as(:thematic_break)
        expect("#hashtag").not_to be_marked_as(:thematic_break)
        expect("\## foo").not_to be_marked_as(:thematic_break)
        expect("    # foo").not_to be_marked_as(:thematic_break)
      end
    end
  end

  describe '#blank_line?' do
    specify do
      markers = [
        "",
        "\n",
        "  ",
        "  \n"
      ]
      expect(markers).to all(be_marked_as(:blank_line))
    end

    specify do
      expect(" a").not_to be_marked_as(:blank_line)
    end
  end

  describe '#block_quotes?' do
    specify do
      markers = [
        "> bar",
        " > bar",
        "  > bar",
        "   > bar",
        ">bar",
        " >bar",
        "  >bar",
        "   >bar"
      ]
      expect(markers).to all(be_marked_as(:block_quotes))
    end

    specify do
      aggregate_failures do
        expect("    > bar").not_to be_marked_as(:block_quotes)
        expect("    >bar").not_to be_marked_as(:block_quotes)
      end
    end
  end

  describe '#bullet_list?' do
    specify do
      markers = [
        "- one",
        " -    one",
        "-",
        "-   ",
        "*",
        " -",
        "  -",
        "   -"
      ]
      expect(markers).to all(be_marked_as(:bullet_list))
    end

    specify do
      aggregate_failures do
        expect("-one").not_to be_marked_as(:bullet_list)
        expect("    *").not_to be_marked_as(:bullet_list)
        expect("    -").not_to be_marked_as(:bullet_list)
      end
    end
  end

  describe '#fenced_code_block?' do
    specify do
      markers = [
        "```",
        "~~~",
        "``````",
        "~~~~",
        " ```",
        "  ```",
        "   ```",
        "```ruby",
        '~~~~    ruby startline=3 $%@#$',
        "````;"
      ]
      expect(markers).to all(be_marked_as(:fenced_code_block))
    end

    specify do
      aggregate_failures do
        expect("``").not_to be_marked_as(:fenced_code_block)
        expect("    ```").not_to be_marked_as(:fenced_code_block)
        expect("``` ```").not_to be_marked_as(:fenced_code_block)
        expect("~~~ ~~").not_to be_marked_as(:fenced_code_block)
      end
    end
  end

  describe '#indented_code_block?' do
    specify do
      markers = [
        "    a simple",
        "      indented code block",
        "        foo",
      ]
      expect(markers).to all(be_marked_as(:indented_code_block))
    end

    specify do
      expect("   foo").not_to be_marked_as(:indented_code_block)
    end
  end

  describe '#thematic_break?' do
    specify do
      markers = [
        "***",
        "---",
        "___",
        " ***",
        "  ***",
        "   ***",
        "_____________________________________",
        " - - -",
        " **  * ** * ** * **",
        "-     -      -      -",
        "- - - -    ",
      ]
      expect(markers).to all(be_marked_as(:thematic_break))
    end

    specify do
      aggregate_failures do
        expect("+++").not_to be_marked_as(:thematic_break)
        expect("===").not_to be_marked_as(:thematic_break)
        expect("    ***").not_to be_marked_as(:thematic_break)
        expect("_ _ _ _ a").not_to be_marked_as(:thematic_break)
        expect("a------").not_to be_marked_as(:thematic_break)
        expect("---a---").not_to be_marked_as(:thematic_break)
        expect(" *-*").not_to be_marked_as(:thematic_break)
      end
    end
  end
end
