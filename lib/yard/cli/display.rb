# frozen_string_literal: true
module YARD
  module CLI
    # Display one object
    # @since 0.8.6
    class Display < Yardoc
      def description; 'Displays a formatted object' end

      def initialize(*args)
        super
        options.format = :text # default for this command
        @layout = nil
        @objects = []
      end

      # Runs the commandline utility, parsing arguments and displaying an object
      # from the {Registry}.
      #
      # @rbs args: Array[String] -- the list of arguments.
      # @rbs return: void
      def run(*args)
        return unless parse_arguments(*args)
        log.puts wrap_layout(format_objects)
      end

      # @rbs return: String -- the output data for all formatted objects
      def format_objects
        @objects.inject([]) do |arr, obj|
          arr.push obj.format(options)
        end.join("\n")
      end

      def wrap_layout(contents)
        return contents unless @layout
        opts = options.merge(
          :contents => contents,
          :object => @objects.first,
          :objects => @objects
        )
        args = [options.template, @layout, options.format]
        Templates::Engine.template(*args).run(opts)
      end

      # Parses commandline options.
      # @rbs args: Array[String] -- each tokenized argument
      def parse_arguments(*args)
        opts = OptionParser.new
        opts.banner = "Usage: yard display [options] OBJECT [OTHER OBJECTS]"
        general_options(opts)
        output_options(opts)
        parse_options(opts, args)

        Registry.load
        @objects = args.map {|o| Registry.at(o) }

        # validation
        return false if @objects.any?(&:nil?)
        verify_markup_options
      end

      def output_options(opts)
        super(opts)
        opts.on('-l', '--layout [LAYOUT]', 'Wraps output in layout template (good for HTML)') do |layout|
          @layout = layout || 'layout'
        end
      end
    end
  end
end
