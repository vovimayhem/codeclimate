module CC
  module Config
    class Default
      attr_reader :engines, :exclude_patterns

      def initialize
        @engines = [structure_engine, duplication_engine]
        @exclude_patterns = %w[
          config/
          db/
          dist/
          features/
          node_modules/
          script/
          spec/
          test/
          tests/
          vendor/
        ]
      end

      private

      def structure_engine
        Engine.new(
          "complexity-ruby",
          enabled: true,
          channel: "beta",
        )
      end

      def duplication_engine
        Engine.new(
          "duplication",
          enabled: true,
          channel: "cronopio",
          config: {
            languages: %w[ruby],
          },
        )
      end
    end
  end
end
