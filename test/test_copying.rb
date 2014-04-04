require 'helper'

class TestCopying < FunWith::Files::TestCase
  context "inside a tmpdir" do
    setup do
      @dir = FilePath.tmpdir
      assert_directory @dir
    end
    
    teardown do
      @dir.rm
      assert_not_directory @dir
    end
    
    should "copy a single file" do
      outdir = @dir.join( "down", "down", "down", "to", "the", "depths" )
      assert_no_file outdir
      outdir.touch_dir
      assert outdir.exist?
      
      infile = FunWith::Files.root( "test", "helper.rb" )
      assert infile.exist?
      
      outfile = outdir.join("copy_of_helper.rb")
      assert !outfile.exist?
      
      infile.cp( outdir )
      assert outdir.join("helper.rb").exist?
      
      infile.cp( outfile )
      assert outfile.exist?
    end
    
    should "copy a directory structure" do
      outdir = @dir.join( "down", "down", "abandon", "all", "hope" )
      indir = FunWith::Files.root( "test" )
      outdir.touch_dir
      indir.cp( outdir )
      
      assert outdir.exist?
      helper_file = outdir.join( "test", "helper.rb" )
      assert helper_file.exist?
      assert_equal indir.join( "helper.rb" ).grep( /FunWith::Files/ ).length, helper_file.grep( /FunWith::Files/ ).length
      
      assert_equal indir.glob(:all).length, outdir.join("test").glob(:all).length
    end
    
    should "symlink masterfully" do
      
    end
  end
end
