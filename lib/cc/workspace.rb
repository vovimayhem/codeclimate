require "pathname"

module CC
  class Workspace
    autoload :Exclusion, "cc/workspace/exclusion"
    autoload :PathTree, "cc/workspace/path_tree"
    autoload :PathEnumerator, "cc/workspace/path_enumerator"

    include Enumerable

    def initialize(path_tree = PathTree.new("."))
      @path_tree = path_tree
    end

    def clone
      self.class.new(path_tree.clone)
    end

    def include?(path)
      path_tree.include?(path)
    end

    def each
      enum = PathEnumerator.new(path_tree).to_enum
      if block_given?
        enum.each { |item| yield item }
      else
        enum
      end
    end

    def paths
      path_tree.all_paths
    end

    def add(paths)
      if paths.present?
        path_tree.include_paths(paths)
      end
    end

    def remove(patterns)
      Array(patterns).each do |pattern|
        path_tree.exclude_paths(Exclusion.new(pattern).expand)
      end
    end

    private

    attr_reader :path_tree
  end
end
