# frozen_string_literal: true

require_relative '../lib/yard_to_rbs_inline/converter'

task :yard_to_rbs_inline do
  target_paths = ['lib/**/*']
    paths = target_paths.flat_map do |target_path|
      Pathname.glob(target_path).select do |path|
        !path.directory? && path.extname == '.rb'
      end
    end.uniq

    paths.each do |path|
      path.write(YardToRbsInline::Converter.new(path.read).convert)
    end
end
