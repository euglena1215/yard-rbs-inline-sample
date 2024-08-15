# frozen_string_literal: true
module YARD
  module Serializers
    # A serializer that writes data to standard output.
    class StdoutSerializer < Base
      # Creates a serializer to print text to stdout
      #
      #   columns, otherwise no wrapping is done.
      # @rbs wrap: Fixnum | nil -- if wrap is a number, wraps text to +wrap+
      def initialize(wrap = nil)
        @wrap = wrap
      end

      # Overrides serialize behaviour to write data to standard output
      def serialize(_object, data)
        print(@wrap ? word_wrap(data, @wrap) : data)
      end

      private

      # Wraps text to a specific column length
      #
      # @rbs text: String -- the text to wrap
      # @rbs _length: Fixnum -- the column length to wrap to
      # @rbs return: String -- the wrapped text
      def word_wrap(text, _length = 80)
        # See ruby-talk/10655 / Ernest Ellingson
        text.gsub(/\t/, "     ").gsub(/.{1,50}(?:\s|\Z)/) do
          ($& + 5.chr).gsub(/\n\005/, "\n").gsub(/\005/, "\n")
        end
      end
    end
  end
end
