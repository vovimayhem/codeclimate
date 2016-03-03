require "net/http"
require "uri"

module CC
  module Analyzer
    BASE_URL = URI.parse("http://10.10.9.130:3000/api/engines")

    class EngineRegistry
      def initialize(dev_mode = false)
      end

      def [](engine_name)
        list[engine_name]
      end

      def list(language: nil, tag: nil)
        url = BASE_URL.dup
        query = {}

        query["language"] = language if language
        query["tag"] = tag if tag
        url.query = query.to_query

        @list ||= JSON.parse(Net::HTTP.get(url))
      end

      def key?(engine_name)
        list.key?(engine_name)
      end

      alias_method :exists?, :key?
    end
  end
end
