require 'helper'

class TestFileManipulation < FunWith::Files::TestCase
  context "testing gsubs" do
    setup do
      @license = FunWith::Files.root("LICENSE.txt")
    end
    
    should "copy LICENSE.txt" do
      copied = @license.cp( "test", "tmp" )
      assert_match /LICENSE\.txt/, copied.to_s
      assert copied.exist?
      assert copied.read.length > 0
    end
    
    should "gsub copy of license.txt" do
      copied = @license.cp( "test", "tmp" )
      copied.file_gsub!( /Bryce Anderson/, "Wilford Brimley" )
      assert copied.size > 1000
      
      assert_equal 1, copied.grep("Wilford Brimley").length
    end
  end
end