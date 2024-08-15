# frozen_string_literal: true

module YardToRbsInline
  # YARD コメントをパースして rbs-inline 形式のコメントに変換するクラス
  class CommentParser
    # @rbs skip
    Argument = Data.define(:name, :type, :description) do
      def to_s
        if description
          "# @rbs #{name}: #{rbs_type} -- #{description}"
        else
          "# @rbs #{name}: #{rbs_type}"
        end
      end

      def rbs_type
        raise 'unsupported type' if type.include?('(') || type.include?(')')

        # TODO: 他にもサポートしきれていないものをサポートする
        type.gsub(', ', ' | ').tr('<', '[').tr('>', ']').gsub('Boolean', 'bool').gsub('NilClass', 'nil')
            .then { |t| t == 'Hash' ? 'Hash[untyped, untyped]' : t }
            .then { |t| t == 'Array' ? 'Array[untyped]' : t }
      end
    end
    # @rbs skip
    Return = Data.define(:type, :description) do
      def to_s
        description ? "# @rbs return: #{rbs_type} -- #{description}" : "# @rbs return: #{rbs_type}"
      end

      def rbs_type
        raise 'unsupported type' if type.include?('(') || type.include?(')')

        # TODO: 他にもサポートしきれていないものをサポートする
        type.gsub(', ', ' | ').tr('<', '[').tr('>', ']').gsub('Boolean', 'bool').gsub('NilClass', 'nil')
            .then { |t| t == 'Hash' ? 'Hash[untyped, untyped]' : t }
            .then { |t| t == 'Array' ? 'Array[untyped]' : t }
      end
    end
    # @rbs skip
    See = Data.define(:description)
    # @rbs skip
    Raise = Data.define(:type, :description)
    # @rbs skip
    Option = Data.define(:name, :type, :opt_name, :description)

    #: () -> void
    def initialize
      reset!
    end

    #: (Array[String]) -> self
    def parse(comments, def_node)
      reset!
      @original_comments = comments
      @def_node = def_node

      comments.each do |comment|
        case comment
        when /# @return \[(?<type>.+?)\](?: (?<description>.*))?/
          @return = Return.new(type: Regexp.last_match(:type), description: Regexp.last_match(:description))
        when /# @param \[(?<type>.+?)\] (?<name>\S+)(?: (?<description>.*))?/
          name = Regexp.last_match(:name)
          type = Regexp.last_match(:type)
          description = Regexp.last_match(:description)
          @arguments << Argument.new(name:, type:, description:)
        # rubocop:disable Lint/DuplicateBranch 下段のブロック内の処理が上段ブロックと同じなのでまとめられると良いが、こちらのスクリプトは一時的に利用するものなのでルールを無視する
        when /# @param (?<name>\S+) \[(?<type>.+?)\](?: (?<description>.*))?/
          name = Regexp.last_match(:name)
          type = Regexp.last_match(:type)
          description = Regexp.last_match(:description)
          @arguments << Argument.new(name:, type:, description:)
        # rubocop:enable Lint/DuplicateBranch
        else
          @other_comments << comment
        end
      end

      self
    end

    #: () -> Array[String]
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def to_rbs_inline_comments
      # YARD と rbs-inline のコメントが混在していると意図しない挙動になるので完全に変換できるもののみ変換する
      return [@return.to_s] if @original_comments.size == 1 && @return
      return @arguments.map(&:to_s) if @original_comments.size == @arguments.size && @arguments.any?
      return @original_comments if @other_comments.any? { |c| c.include?('@') }

      [@other_comments.map(&:to_s), @arguments.map(&:to_s), @return.to_s].flatten.reject(&:empty?)
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    def reset!
      @original_comments = []
      @def_node = nil
      @arguments = []
      @return = nil
      @see = []
      @raise = []
      @options = []
      @other_comments = []
    end
  end
end
