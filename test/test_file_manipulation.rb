require 'helper'

class TestFileManipulation < FunWith::Files::TestCase
  context "testing gsubs" do
    setup do
      @license = FunWith::Files.root("LICENSE.txt")
    end
    
    teardown do
      empty_temp_directory
    end
    
    should "copy LICENSE.txt" do
      copied = @license.cp( "test", "tmp" )
      debugger
      assert_match /LICENSE\.txt/, copied.to_s
      assert_empty_file copied.exist?
      assert copied.read.length > 0
    end
    
    should "gsub copy of license.txt" do
      copied = @license.cp( "test", "tmp" )
      copied.file_gsub!( /Bryce Anderson/, "Wilford Brimley" )
      assert copied.size > 1000
      
      assert_file_contents copied, /Wilford Brimley/
    end
  end
end