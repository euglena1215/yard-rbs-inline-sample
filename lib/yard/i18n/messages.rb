# frozen_string_literal: true
module YARD
  module I18n
    # Acts as a container for {Message} objects.
    #
    # @since 0.8.1
    class Messages
      include Enumerable

      # Creates a new container.
      def initialize
        @messages = {}
      end

      # Enumerates each {Message} in the container.
      #
      # @yieldparam [Message] message the next message object in
      #   the enumeration.
      # @return [void]
      def each(&block)
        @messages.each_value(&block)
      end

      #   or nil if no message for the ID is found.
      # @rbs id: String -- the message ID to perform a lookup on.
      # @rbs return: Message | nil -- a registered message for the given +id+,
      def [](id)
        @messages[id]
      end

      # Registers a {Message}, the message ID of which is +id+. If
      # corresponding +Message+ is already registered, the previously
      # registered object is returned.
      #
      # @rbs id: String -- the ID of the message to be registered.
      # @rbs return: Message -- the registered +Message+.
      def register(id)
        @messages[id] ||= Message.new(id)
      end

      # Checks if this messages list is equal to another messages list.
      #
      # @rbs other: Messages -- the container to compare.
      # @rbs return: bool -- whether +self+ and +other+ is equivalence or not.
      def ==(other)
        other.is_a?(self.class) &&
          @messages == other.messages
      end

      protected

      # @return [Hash{String=>Message}] the set of message objects
      attr_reader :messages
    end
  end
end
