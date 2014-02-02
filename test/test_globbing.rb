require 'helper'

class TestGlobbing < FunWith::Files::TestCase
  should "glob some ruby files from the test/loadable_dir directory" do
    assert FunWith::Files.respond_to?(:root)
    @loadable_dir = FunWith::Files.root("test", "loadable_dir")
    assert @loadable_dir.directory?
    @globs = @loadable_dir.glob( :recursive => true, :ext => "rb" )
    assert_equal 8, @globs.length
  end
end