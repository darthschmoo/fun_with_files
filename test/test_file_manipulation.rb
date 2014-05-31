require 'helper'

class TestFileManipulation < FunWith::Files::TestCase
  context "testing gsubs" do
    setup do
      @license = FunWith::Files.root("LICENSE.txt")
      @tmp_dir = FunWith::Files.root("test", "tmp")
    end
    
    teardown do
      empty_temp_directory
    end
    
    should "copy LICENSE.txt" do
      copied = @license.cp( "test", "tmp" )
      assert_match /LICENSE\.txt/, copied.to_s
      assert_file copied
      assert_file_has_content copied
    end
    
    should "gsub copy of license.txt" do
      copied = @license.cp( "test", "tmp" )
      copied.file_gsub!( /Bryce Anderson/, "Wilford Brimley" )
      assert copied.size > 1000
      
      assert_file_contents copied, /Wilford Brimley/
    end
    
    should "empty files and directories" do
      license_copy = @license.cp( @tmp_dir )
      assert_file( license_copy )
      assert_equal( FunWith::Files.root("test", "tmp", "LICENSE.txt"), license_copy )
      assert_file_has_content( license_copy )
      license_copy.empty!
      assert_empty_file( license_copy )
      assert_zero( license_copy.read.length )
      
      
    end
  end
  
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
    
    should "copy test directory structure to a temporary directory" do
      outdir = @dir.join( "down", "down", "abandon", "all", "hope" )
      indir = FunWith::Files.root( "test" )
      outdir.touch_dir
      indir.cp( outdir )
      
      assert outdir.exist?
      helper_file = outdir.join( "test", "helper.rb" )
      assert_file_has_content helper_file
      assert_equal indir.join( "helper.rb" ).grep( /FunWith::Files/ ).length, helper_file.grep( /FunWith::Files/ ).length
      
      assert_equal indir.glob(:all).length, outdir.join("test").glob(:all).length
    end
    
    should "symlink masterfully" do
      file = @dir.join( "original.txt" )
      file.write( "This is the original file" )
      
      clone = file.symlink( "clone.txt" )
      clone_of_clone = clone.symlink( "clone_of_clone.txt" )
      assert_false( clone_of_clone.original? )
      assert( clone_of_clone.symlink? )
      assert_equal( file, clone_of_clone.original )
      
      assert_file_contents( clone_of_clone, /This is the/ )
    end
  end
end