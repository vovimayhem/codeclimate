module CC
  module CLI
    module Engines
      class Create < EngineCommand

        def initialize(_args = [])
          super

          while @args.present?
            case @args.shift
            when "-l"
              @languages = @args.shift
            when "-t"
              @tags = @args.shift
            when "-d"
              @description = @args.shift
            when "-n"
              @name = @args.shift
            when "-i"
              @image = @args.shift
            end
          end
        end

        def run
          engine_registry.create(
            description: description,
            image: image,
            languages: languages,
            name: name,
            tags: tags,
          )
          puts "Engine created."
        end

        private

        attr_reader :languages, :tags, :description, :name, :image
      end
    end
  end
end
