require "spec_helper"
require "timeout"

class CC::Workspace
  describe PathEnumerator do
    include FileSystemHelpers

    it "walks a tree" do
      within_temp_dir do
        make_tree <<-EOM
          a.txt
          bar/baz.rb
          bar/foo.rb
          bar/moo/zorp.txt
        EOM

        enum = PathEnumerator.new(PathTree.new(".")).to_enum
        expected = %w[./ ./a.txt ./bar ./bar/baz.rb ./bar/foo.rb ./bar/moo ./bar/moo/zorp.txt]
        collect_all(enum).map(&:to_s).must_equal(expected)
      end
    end

    it "can return just an enumerator" do
      within_temp_dir do
        make_tree <<-EOM
          a.txt
          b.txt
        EOM

        enum = PathEnumerator.new(PathTree.new(".")).to_enum
        enum.must_be_instance_of(Enumerator)
        enum.count.must_equal 3
      end
    end

    it "respects paths excluded from the path tree" do
      within_temp_dir do
        make_tree <<-EOM
          a.txt
          bar/baz.rb
          bar/foo.rb
          bar/moo/zorp.txt
        EOM

        path_tree = PathTree.new(".")
        path_tree.exclude_paths(["bar/moo"])
        enum = PathEnumerator.new(path_tree).to_enum
        expected = %w[a.txt bar/baz.rb bar/foo.rb]
        collect_all(enum).map(&:to_s).must_equal(expected)
      end
    end

    it "should only evaluate what it needs to for #any?" do
      within_temp_dir do
        make_tree <<-EOM
          a.txt
          bar/baz.rb
          bar/foo.rb
          bar/moo/zorp.txt
        EOM

        enum = PathEnumerator.new(PathTree.new(".")).to_enum
        all_seen = []
        exists = enum.any? do |path|
          all_seen << path.to_s
          path.to_s == "./a.txt"
        end
        exists.must_equal true
        all_seen.size.must_be(:<, 3)
      end
    end

    it "should handle looping symlink structures" do
      within_temp_dir do
        make_tree <<-EOM
          a/b/thing.txt
        EOM
        Pathname.new("./a/b/c").make_symlink(Pathname.new("./a"))

        Timeout::timeout(3) do
          enum = PathEnumerator.new(PathTree.new(".")).to_enum
          expected = %w[./ ./a ./a/b ./a/b/c ./a/b/thing.txt]
          collect_all(enum).map(&:to_s).must_equal expected
        end
      end
    end

    def collect_all(enum)
      [].tap do |items|
        enum.each { |item| items << item }
      end
    end
  end
end
