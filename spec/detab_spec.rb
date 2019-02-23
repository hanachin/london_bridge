# examples from CommonMark Spec 0.28

RSpec.describe LondonBridge::BlockParser::Detab do
  using described_class

  specify do
    aggregate_failures do
      # Example 1
      expect("\tfoo\tbar\t\tbim\n".detab).to eq("    foo\tbar\t\tbim\n")

      # Example 2
      expect("  \tfoo\tbar\t\tbim\n".detab).to eq("    foo\tbar\t\tbim\n")

      # Example 3
      expect("    a→a\n".detab).to eq("    a→a\n")
      expect("    ὐ→a\n".detab).to eq("    ὐ→a\n")

      # Example 4
      expect("  - foo\n".detab).to eq("  - foo\n")
      expect("\tbar\n".detab).to eq("    bar\n")

      # Example 5
      expect("- foo\n".detab).to eq("- foo\n")
      expect("\t\tbar\n".detab).to eq("        bar\n")

      # Example 6
      expect(">\t\tfoo\n".detab).to eq(">       foo\n")

      # Example 7
      expect("-\t\tfoo\n".detab).to eq("-       foo\n")

      # Example 8
      expect("    foo\n".detab).to eq("    foo\n")
      expect("\tbar\n".detab).to eq("    bar\n")

      # Example 9
      expect(" - foo\n".detab).to eq(" - foo\n")
      expect("   - bar\n".detab).to eq("   - bar\n")
      expect("\t - baz\n".detab).to eq("     - baz\n")

      # Example 10
      expect("#\tFoo\n".detab).to eq("#   Foo\n")

      # Example 11
      expect("*\t*\t*\t\n".detab).to eq("*\t*\t*\t\n")
    end
  end
end
