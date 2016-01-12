module CC
  module Analyzer
    class PathPatterns
      def initialize(patterns, root = Dir.pwd)
        $stderr.puts("DEBUG: PathPatterns: initialize:\n\tpatterns = #{patterns.inspect}\n\troot = #{root}")
        @patterns = patterns
        @root = root
      end

      def match?(path)
        expanded.include?(path)
      end

      def expanded
        @expanded ||= expand
      end

      private

      def expand
        results = Dir.chdir(@root) do
          @patterns.flat_map do |pattern|
            value = optimize_glob(glob_value(pattern))
            Dir.glob(value)
          end
        end

        $stderr.puts("DEBUG: PathPatterns: #expand results = #{results.sort.uniq.inspect}")
        results.sort.uniq
      end

      def glob_value(pattern)
        # FIXME: there exists a temporary workaround whereby **-style globs
        # are translated to **/*-style globs within cc-yaml's custom
        # Glob#value method. It was thought that that would work correctly
        # with Dir.glob but it turns out we have to actually invoke #value
        # directrly for this to work. We need to guard this on class (not
        # respond_to?) because our mocking framework adds a #value method to
        # all objects, apparently.
        if pattern.is_a?(CC::Yaml::Nodes::Glob)
          pattern.value
        else
          pattern
        end
      end

      def optimize_glob(pattern)
        if pattern.ends_with?("/**/*")
          pattern[0..-5]
        else
          pattern
        end
      end
    end
  end
end
