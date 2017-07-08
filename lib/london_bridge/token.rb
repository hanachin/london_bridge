module LondonBridge
  module Token
    # Add .token_name to the base class,
    # .token_name returns name of the token
    def self.included(base)
      def base.token_name
        name.split(/::/).last.gsub(/Token\z/, "").gsub(/(?!^)[A-Z]/) { |c| c + "_" }.downcase
        end
    end

    # @return [String] name of the token
    def name
      self.class.token_name
    end
  end
end
