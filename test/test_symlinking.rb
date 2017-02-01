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
    
    should "create a file and link to it" do
      file = @dir.touch( "Movies", "Basketball", "Shaquille", "cryptohash.dat" )
      assert_fwf_filepath file.directory
      assert_empty_file file
      
      link = file.link( file.up.up.up.join( "hash.dat"), :soft => true )
      assert link.symlink?
    end

    should "create a "

  end
end