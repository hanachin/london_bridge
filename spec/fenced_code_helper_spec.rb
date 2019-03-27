RSpec.describe LondonBridge::BlockParser::FencedCodeHelper do
  using described_class

  describe '#closing_code_fence' do
    example do
      aggregate_failures do
        expect("```".closing_code_fence).to eq("```")
        expect(" ```".closing_code_fence).to eq("```")
        expect("  ```".closing_code_fence).to eq("```")
        expect("   ```".closing_code_fence).to eq("```")
        expect("~~~".closing_code_fence).to eq("~~~")
        expect(" ~~~".closing_code_fence).to eq("~~~")
        expect("  ~~~".closing_code_fence).to eq("~~~")
        expect("   ~~~".closing_code_fence).to eq("~~~")
        expect("````````".opening_code_fence).to eq("````````")
        expect("~~~~~~~~".opening_code_fence).to eq("~~~~~~~~")
 
        expect("```ruby".opening_code_fence).to eq("```")
        expect("~~~ruby".opening_code_fence).to eq("~~~")
        expect { "``~".code_fence_indentation }.to raise_error(LondonBridge::Error)
        expect { "    ```".closing_code_fence }.to raise_error(LondonBridge::Error)
        expect { "    ~~~".closing_code_fence }.to raise_error(LondonBridge::Error)
      end
    end
  end

  describe '#closing_code_fence_of?' do
    example do
      aggregate_failures do
        expect("```".closing_code_fence_of?("```")).to eq(true)
        expect("``` ".closing_code_fence_of?("```")).to eq(true)
        expect(" ```".closing_code_fence_of?("```")).to eq(true)
        expect("  ```".closing_code_fence_of?("```")).to eq(true)
        expect("   ```".closing_code_fence_of?("```")).to eq(true)
        expect("````````".closing_code_fence_of?("```")).to eq(true)
        expect("~~~".closing_code_fence_of?("~~~")).to eq(true)
        expect("~~~ ".closing_code_fence_of?("~~~")).to eq(true)
        expect(" ~~~".closing_code_fence_of?("~~~")).to eq(true)
        expect("  ~~~".closing_code_fence_of?("~~~")).to eq(true)
        expect("   ~~~".closing_code_fence_of?("~~~")).to eq(true)
        expect("~~~~~~~~".closing_code_fence_of?("~~~")).to eq(true)

        expect("```".closing_code_fence_of?("````")).to eq(false)
        expect("~~~".closing_code_fence_of?("~~~~")).to eq(false)
      end
    end
  end

  describe '#code_fence_indentation' do
    example do
      aggregate_failures do
        expect("```".code_fence_indentation).to eq(0)
        expect(" ```".code_fence_indentation).to eq(1)
        expect("  ```".code_fence_indentation).to eq(2)
        expect("   ```".code_fence_indentation).to eq(3)
        expect("~~~".code_fence_indentation).to eq(0)
        expect(" ~~~".code_fence_indentation).to eq(1)
        expect("  ~~~".code_fence_indentation).to eq(2)
        expect("   ~~~".code_fence_indentation).to eq(3)

        expect { "``~".code_fence_indentation }.to raise_error(LondonBridge::Error)
        expect { "    ```".code_fence_indentation }.to raise_error(LondonBridge::Error)
        expect { "    ~~~".code_fence_indentation }.to raise_error(LondonBridge::Error)
      end
    end
  end

  describe '#code_fence_info_string' do
    example do
      aggregate_failures do
        expect("```".code_fence_info_string).to eq(nil)
        expect("``` ".code_fence_info_string).to eq(nil)
        expect(" ```".code_fence_info_string).to eq(nil)
        expect("  ```".code_fence_info_string).to eq(nil)
        expect("   ```".code_fence_info_string).to eq(nil)
        expect("~~~".code_fence_info_string).to eq(nil)
        expect("~~~ ".code_fence_info_string).to eq(nil)
        expect(" ~~~".code_fence_info_string).to eq(nil)
        expect("  ~~~".code_fence_info_string).to eq(nil)
        expect("   ~~~".code_fence_info_string).to eq(nil)
        expect("````````".code_fence_info_string).to eq(nil)
        expect("~~~~~~~~".code_fence_info_string).to eq(nil)
        expect("```ruby".code_fence_info_string).to eq("ruby")
        expect("~~~ruby".code_fence_info_string).to eq("ruby")
        expect("```ruby python".code_fence_info_string).to eq("ruby python")
        expect("~~~ruby python".code_fence_info_string).to eq("ruby python")
        expect("``` ruby python".code_fence_info_string).to eq("ruby python")
        expect("~~~ ruby python".code_fence_info_string).to eq("ruby python")
        expect("```ruby python ".code_fence_info_string).to eq("ruby python")
        expect("~~~ruby python ".code_fence_info_string).to eq("ruby python")
        expect("``` ruby python ".code_fence_info_string).to eq("ruby python")
        expect("~~~ ruby python ".code_fence_info_string).to eq("ruby python")

        expect { "``~".code_fence_info_string }.to raise_error(LondonBridge::Error)
        expect { "    ```".code_fence_info_string }.to raise_error(LondonBridge::Error)
        expect { "    ~~~".code_fence_info_string }.to raise_error(LondonBridge::Error)
      end
    end
  end

  describe '#opening_code_fence' do
    example do
      aggregate_failures do
        expect("```".opening_code_fence).to eq("```")
        expect(" ```".opening_code_fence).to eq("```")
        expect("  ```".opening_code_fence).to eq("```")
        expect("   ```".opening_code_fence).to eq("```")
        expect("~~~".opening_code_fence).to eq("~~~")
        expect(" ~~~".opening_code_fence).to eq("~~~")
        expect("  ~~~".opening_code_fence).to eq("~~~")
        expect("   ~~~".opening_code_fence).to eq("~~~")
        expect("````````".opening_code_fence).to eq("````````")
        expect("~~~~~~~~".opening_code_fence).to eq("~~~~~~~~")
        expect("```ruby".opening_code_fence).to eq("```")
        expect("~~~ruby".opening_code_fence).to eq("~~~")

        expect { "``~".opening_code_fence }.to raise_error(LondonBridge::Error)
        expect { "    ```".opening_code_fence }.to raise_error(LondonBridge::Error)
        expect { "    ~~~".opening_code_fence }.to raise_error(LondonBridge::Error)
      end
    end
  end
end
