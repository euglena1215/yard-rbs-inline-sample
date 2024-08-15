# frozen_string_literal: true
module YARD
  module Templates::Helpers
    # Helpers for UML template format
    module UMLHelper
      # Official UML visibility prefix syntax for an object given its visibility
      # @rbs object: CodeObjects::Base -- the object to retrieve visibility for
      # @rbs return: String -- the UML visibility prefix
      def uml_visibility(object)
        case object.visibility
        when :public;    '+'
        when :protected; '#'
        when :private;   '-'
        end
      end

      # Formats the path of an object for Graphviz syntax
      # @rbs object: CodeObjects::Base -- an object to format the path of
      # @rbs return: String -- the encoded path
      def format_path(object)
        object.path.gsub('::', '_')
      end

      # Encodes text in escaped Graphviz syntax
      # @rbs text: String -- text to encode
      # @rbs return: String -- the encoded text
      def h(text)
        text.to_s.gsub(/(\W)/, '\\\\\1')
      end

      # Tidies data by formatting and indenting text
      # @rbs data: String -- pre-formatted text
      # @rbs return: String -- tidied text.
      def tidy(data)
        indent = 0
        data.split(/\n/).map do |line|
          line.gsub!(/^\s*/, '')
          next if line.empty?
          indent -= 1 if line =~ /^\s*\}\s*$/
          line = (' ' * (indent * 2)) + line
          indent += 1 if line =~ /\{\s*$/
          line
        end.compact.join("\n") + "\n"
      end
    end
  end
end
