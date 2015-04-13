require 'helper'

class TestGlobbing < FunWith::Files::TestCase
  context "testing globbing" do
    setup do
      @loadable_dir = FunWith::Files.root "test", "loadable_dir"
      @glob_dir     = FunWith::Files.root "test", "glob_dir" 
      assert @loadable_dir.directory?
      assert @glob_dir.directory?
    end
  
    should "glob some ruby files from the test/loadable_dir directory" do
      globs = @loadable_dir.glob( :recursive => true, :ext => "rb" )
      assert_equal 8, globs.length
    end
  
    should "only glob the top-level when recurse is false" do
      globs = @loadable_dir.glob( :recurse => false )
      assert_equal( 5, globs.length )

      globs = @loadable_dir.glob( :all, :recurse => false )
      assert_equal( 5, globs.length )
    end
    
    should "glob everything in the tree by default" do
      globs = @loadable_dir.glob
      assert_equal( 13, globs.length )

      globs = @loadable_dir.glob(:all)
      assert_equal( 13, globs.length )
    end
    
    should "glob only files when an extension is given" do
      globs = @loadable_dir.glob( :recurse => true, :ext => :rb )
      assert_equal( 8, globs.length )
    end
    
    should "not search subdirectories when :recurse => false" do
      globs = @loadable_dir.glob( :recurse => false, :ext => :rb )
      assert_length 0, globs
    end
    
    should "NOT search subdirectories when :recurse is unspecified" do
      globs = @loadable_dir.glob :ext => :rb
      assert_length 0, globs
    end
    
    should "glob a dot file" do
      globs = @glob_dir.glob( :recurse => false, :dots => true )
      assert_length 1, globs
    end
    
    should "not glob a dot file when :dots => false" do
      globs = @glob_dir.glob( :recurse => false, :dots => false )
      assert_length( 0, globs )
    end
    
    should "ignore a dot file by default" do
      globs = @glob_dir.glob( :recurse => false )  # no dots by default
      assert_length( 0, globs )
    end
  end
end