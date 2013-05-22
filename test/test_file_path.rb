require 'helper'

include FunWith::Files

class TestFilePath < Test::Unit::TestCase
  context "testing basics" do
    setup do
      
    end
    
    should "initialize kindly" do
      f1 = FilePath.new( "/", "bin", "bash" )
      f2 = "/".fwf_filepath( "bin", "bash" )
      assert f1.exist?
      assert f2.exist?
    end
    
    should "go up/down when asked" do
      f1 = FilePath.new( "/", "home", "users", "monkeylips", "ask_for_floyd" )
      f2 = FilePath.new( "/", "home", "users" )
      root = FilePath.new( "/" )
      
      assert_equal f2, f1.up.up
      assert_equal root, f1.up.up.up.up.up.up.up
      
      #invoking up didn't change original
      assert_match /ask_for_floyd/, f1.to_s
      
      assert_equal f1, f2.down( "monkeylips" ).down( "ask_for_floyd" )
      assert_equal f1, f2.down( "monkeylips", "ask_for_floyd" )
      
      #invoking down didn't change original
      assert_no_match /ask_for_floyd/, f2.to_s
    end
    
    should "convert from string" do
      str = "/"
      f1 = FilePath.new(str)
      f2 = str.fwf_filepath
      
      assert_equal f1, f2
    end
    
    should "convert from pathname" do
      str = "/"
      f1 = FilePath.new(str)
      f2 = Pathname.new(str).fwf_filepath
      
      assert_equal f1, f2
      
      f3 = f1.join( "bin", "bash" )
      f4 = Pathname.new( str ).fwf_filepath( "bin", "bash" )
      
      assert_equal f3, f4
    end
  end
  
  context "test glob" do
    setup do
      @data_dir = FunWith::Files.root( 'test', 'data' )
    end
    
    should "glob items in test/data directory" do
      files = @data_dir.glob(:all)
      assert_equal 3, files.length
      files = @data_dir.glob(:all, :flags => [File::FNM_DOTMATCH])
      assert_equal 7, files.length
    end
    
    should "glob with case insensitive flag" do
      files = @data_dir.glob("grep1.txt")
      assert_equal 1, files.length
      
      # TODO: Case sensitive search?
      # files = @data_dir.glob("grep1.txt", :flags => [File::FNM_CASEFOLD])
      # assert_equal 2, files.length
      # files = @data_dir.glob("grep1.txt", :sensitive => true)
      # assert_equal 2, files.length
    end
  end
  
  
end