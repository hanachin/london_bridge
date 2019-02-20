RSpec.describe LondonBridge::BlockParser::Detab do
  using described_class

  specify do
    aggregate_failures do
      # from CommonMark spec
      expect("\tfoo\tbar\t\tbim\n".detab).to eq("    foo\tbar\t\tbim\n")

      expect("  \tfoo\tbar\t\tbim\n".detab).to eq("    foo\tbar\t\tbim\n")

      expect("    a→a\n".detab).to eq("    a→a\n")
      expect("    ὐ→a\n".detab).to eq("    ὐ→a\n")

      expect("  - foo\n".detab).to eq("  - foo\n")
      expect("\tbar\n".detab).to eq("    bar\n")

      expect("- foo\n".detab).to eq("- foo\n")
      expect("\t\tbar\n".detab).to eq("        bar\n")

      expect(">\t\tfoo\n".detab).to eq(">       foo\n")

      expect("-\t\tfoo\n".detab).to eq("-       foo\n")

      expect("    foo\n".detab).to eq("    foo\n")
      expect("\tbar\n".detab).to eq("    bar\n")

      expect(" - foo\n".detab).to eq(" - foo\n")
      expect("   - bar\n".detab).to eq("   - bar\n")
      expect("\t - baz\n".detab).to eq("     - baz\n")

      expect("#\tFoo\n".detab).to eq("#   Foo\n")

      expect("*\t*\t*\t\n".detab).to eq("*\t*\t*\t\n")
    end
  end
end
