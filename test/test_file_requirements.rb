require 'helper'

class TestFileRequirements < FunWith::Files::TestCase
  context "testing FileRequirements methods" do
    setup do
      @tmp_dir = FunWith::Files.root("test", "tmp")
      @file    = @tmp_dir.join("file.txt").touch
      @dir     = @tmp_dir.join("dir").touch_dir
    end
    
    teardown do
      empty_temp_directory
    end
    
    context "needs_to_exist()" do
      should "raise an error when a file doesn't exist" do
        assert_raises Errno::ENOENT do
          @tmp_dir.join("missing_file.txt").needs_to_exist
        end
      end
      
      should "raise an error when a file isn't empty" do
        assert_raises Errors::FileNotEmpty do
          @file.append("Zorpy was here")
          @file.needs_to_be_empty
        end
      end
      
      should "raise an error when a file oughta be a directory" do
        assert_raises Errors::NotADirectory do
          @file.must_be_directory
        end
      end
    end
  end
end