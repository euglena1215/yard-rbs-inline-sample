# frozen_string_literal: true
require "set"

module YARD
  module I18n
    # +Message+ is a translation target message. It has message ID as
    # {#id} and some properties {#locations} and {#comments}.
    #
    # @since 0.8.1
    class Message
      # @return [String] the message ID of the translation target message.
      attr_reader :id

      # @return [Set] the set of locations. Location is an array of
      # path and line number where the message is appeared.
      attr_reader :locations

      # @return [Set] the set of comments for the messages.
      attr_reader :comments

      # Creates a translate target message for message ID +id+.
      #
      # @rbs id: String -- the message ID of the translate target message.
      def initialize(id)
        @id = id
        @locations = Set.new
        @comments = Set.new
      end

      # Adds location information for the message.
      #
      # @rbs path: String -- the path where the message appears.
      # @rbs line: Integer -- the line number where the message appears.
      # @rbs return: void
      def add_location(path, line)
        @locations << [path, line]
      end

      # Adds a comment for the message.
      #
      # @rbs comment: String -- the comment for the message to be added.
      # @rbs return: void
      def add_comment(comment)
        @comments << comment unless comment.nil?
      end

      # @rbs other: Message -- the +Message+ to be compared.
      # @rbs return: bool -- checks whether this message is equal to another.
      def ==(other)
        other.is_a?(self.class) &&
          @id == other.id &&
          @locations == other.locations &&
          @comments == other.comments
      end
    end
  end
end
