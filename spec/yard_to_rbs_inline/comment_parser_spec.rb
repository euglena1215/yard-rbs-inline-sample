# frozen_string_literal: true

require 'prism'
require 'yard_to_rbs_inline/comment_parser'

RSpec.describe YardToRbsInline::CommentParser do
  describe '#to_rbs_inline_comments' do
    def to_def_node(source)
      Prism.parse(source).value.child_nodes[0].body[0]
    end

    describe '@return' do
      context '@return だけがある場合' do
        let(:comments) do
          [
            '# @return [String]'
          ]
        end
        let(:def_node) do
          to_def_node(<<~RUBY)
            def foo
              'foo'
            end
          RUBY
        end

        it 'rbs-inline 形式のコメントを返す' do
          expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
            .to eq ['# @rbs return: String']
        end

        context '説明付きの場合' do
          let(:comments) do
            [
              '# @return [String] 説明'
            ]
          end

          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo
                'foo'
              end
            RUBY
          end

          it 'rbs-inline 形式のコメントを返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq ['# @rbs return: String -- 説明']
          end
        end

        context 'Arrayの場合' do
          let(:comments) do
            [
              '# @return [Array<String>]'
            ]
          end

          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo
                ['foo']
              end
            RUBY
          end

          it 'rbs-inline 形式のコメントを返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq ['# @rbs return: Array[String]']
          end
        end

        context '要素の型が未指定のArrayの場合' do
          let(:comments) do
            [
              '# @return [Array]'
            ]
          end

          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo
                ['foo']
              end
            RUBY
          end

          it 'rbs-inline 形式のコメントを返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq ['# @rbs return: Array[untyped]']
          end
        end

        context '要素の型が未指定のHashの場合' do
          let(:comments) do
            [
              '# @return [Hash]'
            ]
          end

          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo
                { 'foo' => 1 }
              end
            RUBY
          end

          it 'rbs-inline 形式のコメントを返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq ['# @rbs return: Hash[untyped, untyped]']
          end
        end
      end

      context 'NilClassの場合' do
        let(:comments) do
          [
            '# @return [NilClass]'
          ]
        end

        let(:def_node) do
          to_def_node(<<~RUBY)
            def foo
              nil
            end
          RUBY
        end

        it 'NilClass を nil に変換した結果を返す' do
          expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
            .to eq ['# @rbs return: nil']
        end
      end

      context '@return 以外のコメントもある場合' do
        context '@return / @param 以外に `@` が含まれている場合' do
          let(:comments) do
            [
              '# その他コメント',
              '# @return [Boolean]',
              '# @raise [ActiveRecord::RecordInvalid]'
            ]
          end
          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo(name)
                'foo'
              end
            RUBY
          end

          it '変換せずにコメントをそのまま返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq [
                '# その他コメント',
                '# @return [Boolean]',
                '# @raise [ActiveRecord::RecordInvalid]'
              ]
          end
        end

        context '@return / @param 以外に `@` が含まれていない場合' do
          let(:comments) do
            [
              '# その他コメントv1',
              '# @return [Boolean]',
              '# その他コメントv2'
            ]
          end
          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo(name)
                'foo'
              end
            RUBY
          end

          it '@return のみ rbs-inline 形式に変換され、それ他のコメントは上部に並び替えられた状態でコメントを返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq [
                '# その他コメントv1',
                '# その他コメントv2',
                '# @rbs return: bool'
              ]
          end
        end
      end
    end

    describe '@param' do
      context '@param だけがある場合' do
        let(:comments) do
          [
            '# @param [String] name'
          ]
        end
        let(:def_node) do
          to_def_node(<<~RUBY)
            def foo(name)
              name
            end
          RUBY
        end

        it 'rbs-inline 形式のコメントを返す' do
          expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
            .to eq ['# @rbs name: String']
        end

        context '説明付きの場合' do
          let(:comments) do
            [
              '# @param [String] name 説明'
            ]
          end

          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo(name)
                'foo'
              end
            RUBY
          end

          it 'rbs-inline 形式のコメントを返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq ['# @rbs name: String -- 説明']
          end
        end

        context 'NilClassの場合' do
          let(:comments) do
            [
              '# @param [String, NilClass] name'
            ]
          end

          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo(name)
                name
              end
            RUBY
          end

          it 'NilClass を nil に変換したコメントを返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq ['# @rbs name: String | nil']
          end
        end

        context 'コメントの並び順が「引数名 -> 型」の場合' do
          let(:comments) do
            [
              '# @param name [String] description'
            ]
          end
          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo(name)
                name
              end
            RUBY
          end

          it 'rbs-inline 形式のコメントを返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq ['# @rbs name: String -- description']
          end
        end
      end

      context '@param 以外のコメントもある場合' do
        context '@return / @param 以外に `@` が含まれている場合' do
          let(:comments) do
            [
              '# その他コメント',
              '# @param [Hash] payload',
              '# @option payload [String] :title',
              '# refs: https://example.com'
            ]
          end
          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo(hash)
                hash
              end
            RUBY
          end

          it '変換せずにコメントをそのまま返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq [
                '# その他コメント',
                '# @param [Hash] payload',
                '# @option payload [String] :title',
                '# refs: https://example.com'
              ]
          end
        end

        context '@return / @param 以外に `@` が含まれていない場合' do
          let(:comments) do
            [
              '# その他コメントv1',
              '# @param [String] name',
              '# その他コメントv2'
            ]
          end
          let(:def_node) do
            to_def_node(<<~RUBY)
              def foo(name)
                name
              end
            RUBY
          end

          it '@param のみ rbs-inline 形式に変換され、それ他のコメントは上部に並び替えられた状態でコメントを返す' do
            expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
              .to eq [
                '# その他コメントv1',
                '# その他コメントv2',
                '# @rbs name: String'
              ]
          end
        end
      end
    end

    describe '@return & @param' do
      let(:comments) do
        [
          '# @return [String]',
          '# @param [String] name 説明',
          'その他コメント'
        ]
      end

      let(:def_node) do
        to_def_node(<<~RUBY)
          def foo(name)
            'foo'
          end
        RUBY
      end

      it 'rbs-inline の形式に変換され、@returnの位置が最後、その他コメントが最初になるように並び替えられたコメントを返す' do
        expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
          .to eq [
            'その他コメント',
            '# @rbs name: String -- 説明',
            '# @rbs return: String'
          ]
      end
    end

    describe 'その他のコメント' do
      let(:comments) do
        [
          '# その他コメント',
          '# @!sig () -> void',
          '# refs: https://example.com',
          '# @raise [ActiveRecord::RecordInvalid]'
        ]
      end
      let(:def_node) do
        to_def_node(<<~RUBY)
          def foo
            'foo'
          end
        RUBY
      end

      it 'そのままのコメントを返す' do
        expect(described_class.new.parse(comments, def_node).to_rbs_inline_comments)
          .to eq [
            '# その他コメント',
            '# @!sig () -> void',
            '# refs: https://example.com',
            '# @raise [ActiveRecord::RecordInvalid]'
          ]
      end
    end
  end
end
