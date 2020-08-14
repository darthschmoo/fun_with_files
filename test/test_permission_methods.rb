require 'helper'

class TestPermissionMethods < FunWith::Files::TestCase
  context "checking for availability of permission methods" do
    setup do
      @filepath = FunWith::Files::FilePath.new("/")
    end
    
    should "have permission methods" do
      assert_respond_to @filepath, :readable?
      assert_respond_to @filepath, :writable?
      assert_respond_to @filepath, :executable?
      assert_respond_to @filepath, :chown
      assert_respond_to @filepath, :chmod
      assert_respond_to @filepath, :owner
    end
    
    should "have a root owner" do
      assert_equal "root", @filepath.owner
    end
  end
end