require "cc/cli/command"

module CC
  module CLI
    class Analyze < Command
      ARGUMENT_LIST = "[-f format] [-e engine[:channel]] [path]".freeze
      SHORT_HELP = "Run analysis with the given arguments".freeze
      HELP = "#{SHORT_HELP}\n" \
        "\n" \
        "    -f <format>, --format <format>   Format of output. Possible values: #{CC::Analyzer::Formatters::FORMATTERS.keys.join ", "}\n" \
        "    -e <engine[:channel]>            Engine to run. Can be specified multiple times.\n" \
        "    --dev                            Run in development mode. Engines installed locally that are not in the manifest will be run.\n" \
        "    path                             Path to check. Can be specified multiple times.".freeze

      include CC::Analyzer

      def initialize(_args = [])
        super
        @engine_options = []
        @path_options = []

        process_args
      end

      def run
        formatter.started

        Dir.chdir(MountedPath.code.container_path) do
          engines.each do |engine|
            formatter.engine_running(engine) do
              run_engine(engine)
            end
          end
        end

        formatter.finished
      ensure
        formatter.close if formatter.respond_to?(:close)
      end

      private

      attr_reader :engine_options, :path_options

      def process_args
        while (arg = @args.shift)
          case arg
          when "-f"
            @formatter = Formatters.resolve(@args.shift).new(filesystem)
          when "-e", "--engine"
            @engine_options << @args.shift
          when "--dev"
            @dev_mode = true
          else
            @path_options << arg
          end
        end
      rescue Formatters::Formatter::InvalidFormatterError => e
        fatal(e.message)
      end

      def engines
        if @engine_options.present?
          raise ArgumentError, "-e not supported at the moment"
        else
          CLI.config.engines
        end
      end

      def run_engine(engine)
        engine_details = CLI.registry.fetch_engine_details(engine, development: @dev_mode)
        runnable_engine = CC::Analyzer::Engine.new(
          engine.name,
          {
            "image" => engine_details.image,
            "command" => engine_details.command,
          },
          engine.to_config_json.merge(
            include_paths: workspace.paths,
          ),
          engine.container_label,
        )

        runnable_engine.run(formatter, ContainerListener.new)
      end

      def formatter
        @formatter ||= Formatters::PlainTextFormatter.new(filesystem)
      end

      def workspace
        @workspace ||= Workspace.new.tap do |workspace|
          workspace.add(@path_options)
          unless @path_options.present?
            workspace.remove([".git"])
            workspace.remove(CLI.config.exclude_patterns)
          end
        end
      end
    end
  end
end
