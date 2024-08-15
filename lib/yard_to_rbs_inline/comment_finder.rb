# frozen_string_literal: true

require 'prism'
require 'active_support/core_ext/enumerable'

module YardToRbsInline
  # Rubyプログラムを走査してコメントを取得するクラス
  class CommentFinder < Prism::Visitor
    class NodeWithComments
      attr_reader :node #: Prism::DefNode
      attr_reader :comments #: Array[String]
      attr_reader :comment_start_offset #: Integer?
      attr_reader :comment_end_offset #: Integer?
      attr_reader :comment_indent #: Integer?

      # @rbs node: Prism::DefNode
      # @rbs comments: Array[String]
      # @rbs comment_start_offset: Integer?
      # @rbs comment_end_offset: Integer?
      # @rbs comment_indent: Integer?
      # @rbs return: void
      def initialize(node:, comments:, comment_start_offset:, comment_end_offset:, comment_indent:)
        @node = node
        @comments = comments
        @comment_start_offset = comment_start_offset
        @comment_end_offset = comment_end_offset
        @comment_indent = comment_indent
      end
    end

    #: (Prism::Result) { (NodeWithComments) -> void } -> void
    def self.each_comments(result, &)
      node_with_comments = []
      result.value.accept(new(node_with_comments, result))
      node_with_comments.each(&)
    end

    # @rbs @node_with_comments: Array[NodeWithComments]
    # @rbs @comment_by_start_line: Hash[Integer, Prism::Comment]

    attr_reader :node_with_comments #: Array[NodeWithComments]
    attr_reader :comment_by_start_line #: Hash[Integer, Prism::Comment]
    private :node_with_comments, :comment_by_start_line

    # rubocop:disable Lint/MissingSuper
    #: (Array<NodeWithComments>, Prism::Result) -> void
    def initialize(node_with_comments, result)
      @node_with_comments = node_with_comments
      @comment_by_start_line = result.comments.index_by { |comment| comment.location.start_line }
    end
    # rubocop:enable Lint/MissingSuper

    # @rbs override
    def visit_def_node(node)
      @node_with_comments << NodeWithComments.new(node:, **fetch_comment_chunk(node))
    end

    private

    # メソッド上部のコメントを取得する。コメントが複数行に跨っている場合は全て取得し、コメントの開始位置、終了位置、インデントを返す
    #
    # rubocop:disable Layout/LineLength
    # @rbs node: Prism::DefNode
    # @rbs return: { comments: Array[String], comment_start_offset: Integer?, comment_end_offset: Integer?, comment_indent: Integer? }
    # rubocop:enable Layout/LineLength
    def fetch_comment_chunk(node)
      method_start_line = node.location.start_line
      line_index = method_start_line - 1
      comments = []
      comment_start_offset = nil
      comment_end_offset = nil
      comment_indent = nil
      while (comment = comment_by_start_line[line_index])
        comments << comment.location.slice
        comment_start_offset = comment.location.start_character_offset
        comment_end_offset ||= comment.location.end_character_offset
        comment_indent = comment.location.start_column
        line_index -= 1
      end

      {
        comments: comments.reverse, # コメントの文字列の配列
        comment_start_offset:, # プログラム中のコメントのかたまりの開始位置
        comment_end_offset:, # プログラム中のコメントのかたまりの終了位置
        comment_indent: # コメントにおけるインデントの深さ。コメントが複数行に跨っている場合は最初の行のインデントを返す
      }
    end
  end
end
