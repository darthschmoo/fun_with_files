require 'helper'

class TestStatMethods < FunWith::Files::TestCase
  
  context "checking for availability of stat-enabling methods" do
    setup do
      @filepath = FunWith::Files::FilePath.new("/")
    end
    
    should "have stat methods" do
      assert_respond_to @filepath, :stat
      assert_respond_to @filepath, :inode
      assert_respond_to @filepath, :birthtime  # this (and many others) come from Pathname
    end
    
  end
end