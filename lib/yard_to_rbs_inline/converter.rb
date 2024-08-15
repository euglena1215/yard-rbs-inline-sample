# frozen_string_literal: true

require_relative './comment_finder'
require_relative './replacer'
require_relative './comment_parser'

module YardToRbsInline
  # Rubyプログラム全体を文字列として受け取って YARD コメントが含まれていればそれを rbs-inline 形式のコメントに変換するクラス
  class Converter
    attr_reader :content #: String
    private :content

    #: (String) -> void
    def initialize(content)
      @content = content
    end

    #: () -> String
    def convert
      # プログラム内に `# @` が存在しない場合は変換する必要がないのでそのまま返す
      return content unless content.include?('# @')

      replacer = Replacer.new(content)

      result = Prism.parse(content)
      CommentFinder.each_comments(result) do |node_with_comment|
        next if node_with_comment.comment_start_offset.nil? ||
                node_with_comment.comment_end_offset.nil? ||
                node_with_comment.comment_indent.nil?

        replacer.add_replacement(
          node_with_comment.comment_start_offset,
          node_with_comment.comment_end_offset,
          CommentParser.new.parse(node_with_comment.comments, node_with_comment.node).to_rbs_inline_comments
                       .join("\n#{' ' * node_with_comment.comment_indent}")
        )
      end

      replacer.execute
    end
  end
end
