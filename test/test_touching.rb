require 'helper'

include FunWith::Files

class TestTouching < Test::Unit::TestCase
  context "inside a tmpdir" do
    setup do
      @dir = FilePath.tmpdir
    end
    
    teardown do
      FileUtils.rmtree( @dir )
    end
    
    should "touch a subdirectory" do
      @subdir = @dir.touch_dir( "Movies", "Basketball", "Shaquille" )
      assert_kind_of FilePath, @subdir
      assert @subdir.directory?
      assert_equal @dir, @subdir.up.up.up

      @subdir_file = @dir.join( "Movies", "Basketball", "Shaquille", "JamNinja.m4v" ).touch
      assert_kind_of FilePath, @subdir_file
      assert @subdir_file.file?
      assert_equal @dir, @subdir_file.dirname.up.up.up
    end
    
    should "accept touch_dir on existing directory" do
      assert_nothing_raised do
        @dir.touch_dir
      end
    end
  end
end