# frozen_string_literal: true

module YardToRbsInline
  # 1つの文字列に対して複数の置換を何も考えずに行うとするとオフセット計算がずれてしまう。
  # そのためのオフセット計算をいい感じに行い、適切に置換を行うためのクラス
  class Replacer
    #: (String) -> void
    def initialize(content)
      @content = content
      @replacements = []
    end

    #: (Integer, Integer, String) -> void
    def add_replacement(start_offset, end_offset, replace_text)
      @replacements << [start_offset, end_offset, replace_text]
    end

    #: () -> String
    def execute
      # 後ろから順番に置換していくことでオフセット計算がずれないようにしている
      @replacements.sort_by { |_, end_offset, _| end_offset }.reverse_each do |start_offset, end_offset, replace_text|
        @content[start_offset...end_offset] = replace_text
      end
      @content
    end
  end
end
