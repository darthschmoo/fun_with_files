require 'helper'

class TestGlobbing < FunWith::Files::TestCase
  context "testing globbing" do
    setup do
      @loadable_dir = FunWith::Files.root("test", "loadable_dir")
      assert @loadable_dir.directory?
    
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
  end
end