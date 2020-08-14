require 'helper'

class TestRootPath < FunWith::Files::TestCase
  should "add a root to a module" do
    mod = Module.new
    path = File.join("/", "usr", "bin")
    rootify_and_test( mod, path )
  end
  
  should "add a root to an object" do
    obj = Object.new
    path = File.join("/", "usr", "bin")
    rootify_and_test( obj, path )
  end
  
  context "FunWith::Files.root" do
    should "be a directory" do
      assert_directory( FunWith::Files.root )
      assert_empty_directory( FunWith::Files.root( :test, :tmp ) )
      assert_empty_directory( FunWith::Files.root / :test / :tmp )
      assert_empty_directory( FunWith::Files.root / "test" / "tmp" )
      
    end
  end
  
  def rootify_and_test( obj, path )
    RootPath.rootify( obj, path )
    assert obj.respond_to?(:root)
    assert obj.respond_to?(:set_root_path)
    assert_equal path, obj.root.to_s
  end
end
