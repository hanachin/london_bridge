using LondonBridge::BlockParser::Markers

RSpec::Matchers.define(:be_marked_as) { |type| match { |actual| actual.public_send("#{type}?") } }
