require "set"

module CC
  class Workspace
    class PathEnumerator
      def initialize(path_tree)
        @path_tree = path_tree
        @seen_real_dirs = Set.new
      end

      def to_enum
        Enumerator.new do |yielder|
          root_paths.each do |root_path|
            pathname_each(yielder, Pathname.new(root_path))
          end
        end
      end

      private

      attr_reader :path_tree

      def pathname_each(yielder, pathname)
        yielder.yield pathname
        if pathname.directory? && !dir_seen?(pathname)
          saw_dir(pathname)
          pathname.children.each { |child| pathname_each(yielder, child) }
        end
      end

      def root_paths
        @root_paths = path_tree.all_paths
      end

      def saw_dir(dir)
        @seen_real_dirs << dir.realpath
      end

      def dir_seen?(dir)
        @seen_real_dirs.include?(dir.realpath)
      end
    end
  end
end
