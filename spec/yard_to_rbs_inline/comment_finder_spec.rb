# frozen_string_literal: true

require 'yard_to_rbs_inline/comment_finder'
require 'prism'

RSpec.describe YardToRbsInline::CommentFinder do
  describe '.each_comments' do
    let(:parse_result) do
      Prism.parse(<<~'RUBY')
        # frozen_string_literal: true

        # クラスコメント
        class Foo
          # @return [String]
          def method1
            'bar'
          end

          # 関係ないコメント

          # @param [String] name
          # @return [String]
          def method2(name)
            "Hello, #{name}!"
          end

          # TODO: このメソッドを実装すること
          def method3
            nil
          end
        end
      RUBY
    end

    it 'メソッドとコメントの組が取得できる' do
      expected = [
        {
          method_name: :method1,
          comments: ['# @return [String]'],
          comment_start_offset: 53, comment_end_offset: 71,
          comment_indent: 2
        },
        {
          method_name: :method2,
          comments: ['# @param [String] name', '# @return [String]'],
          comment_start_offset: 119, comment_end_offset: 162,
          comment_indent: 2
        },
        {
          method_name: :method3,
          comments: ['# TODO: このメソッドを実装すること'],
          comment_start_offset: 214, comment_end_offset: 235,
          comment_indent: 2
        }
      ]

      described_class.each_comments(parse_result) do |node_with_comments|
        expected_node = expected.shift
        expect(node_with_comments.node.name).to eq(expected_node[:method_name])
        expect(node_with_comments.comments).to eq(expected_node[:comments])
        expect(node_with_comments.comment_start_offset).to eq(expected_node[:comment_start_offset])
        expect(node_with_comments.comment_end_offset).to eq(expected_node[:comment_end_offset])
        expect(node_with_comments.comment_indent).to eq(expected_node[:comment_indent])
      end

      expect(expected).to be_empty
    end
  end
end
