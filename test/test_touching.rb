require 'helper'

class TestTouching < FunWith::Files::TestCase
  context "inside a tmpdir" do
    setup do
      @dir = FilePath.tmpdir
    end
    
    teardown do
      @dir.rm
      assert_equal false, @dir.directory?
    end
    
    should "touch a subdirectory" do
      @subdir = @dir.touch_dir( "Movies", "Basketball", "Shaquille" )
      assert_fwf_filepath @subdir
      assert_directory @subdir
      assert_equal @dir, @subdir.up.up.up

      @subdir_file = @dir.join( "Movies", "Basketball", "Shaquille", "JamNinja.m4v" ).touch
      
      assert_fwf_filepath @subdir_file
      assert_empty_file @subdir_file
      assert_equal @dir, @subdir_file.dirname.up.up.up
    end
    
    should "accept touch_dir on existing directory" do
      assert_nothing_raised do
        @dir.touch_dir
      end
    end
  end
end