# frozen_string_literal: false

# 文字列に対して破壊的変更を行いたいので frozen_string_literal: false にしている

require 'yard_to_rbs_inline/replacer'

RSpec.describe YardToRbsInline::Replacer do
  describe '#execute' do
    let(:content) { '1 22 333 4444 55555' }

    it 'オフセット計算が正しく複数回の置換が行われる' do
      replacer = described_class.new(content)
      replacer.add_replacement(2, 4, 'replaced') # 22 to replaced
      replacer.add_replacement(0, 1, 'replaced') # 1 to replaced
      replacer.add_replacement(5, 8, 'replaced') # 333 to replaced
      replacer.add_replacement(14, 19, 'replaced') # 55555 to replaced
      replacer.add_replacement(9, 13, 'replaced') # 4444 to replaced

      expect(replacer.execute).to eq 'replaced replaced replaced replaced replaced'
    end
  end
end
