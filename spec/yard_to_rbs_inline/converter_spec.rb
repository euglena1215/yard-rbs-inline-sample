# frozen_string_literal: false

# 文字列に対して破壊的変更を行いたいので frozen_string_literal: false にしている

require 'yard_to_rbs_inline/converter'

RSpec.describe YardToRbsInline::Converter do
  describe '#convert' do
    let(:content) do
      <<~'RUBY'
        # frozen_string_literal: true

        class Foo
          # @return [String]
          def method1
            'bar'
          end

          # @param [String] name
          # @return [String]
          def method2(name)
            "Hello, #{name}!"
          end
        end
      RUBY
    end

    it '変換した文字列を返す' do
      expect(described_class.new(content).convert).to eq <<~'RUBY'
        # frozen_string_literal: true

        class Foo
          # @rbs return: String
          def method1
            'bar'
          end

          # @rbs name: String
          # @rbs return: String
          def method2(name)
            "Hello, #{name}!"
          end
        end
      RUBY
    end
  end
end
