module CC
  module CLI
    module Engines
      class List < EngineCommand

        def initialize(_args = [])
          super

          case @args.shift
          when "-l"
            @language = @args.shift
          when "-t"
            @tag = @args.shift
          end
        end

        def run
          engines = engine_registry.list(language: language, tag: tag)

          if engines.size > 0
            say "Available engines:"

            engines.sort_by { |name, _| name }.each do |name, attributes|
              say "- #{name}: #{attributes['description']}"
            end
          end
        end

        private

        attr_reader :language, :tag
      end
    end
  end
end
