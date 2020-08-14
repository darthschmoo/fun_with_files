require 'helper'

class TestMoving < FunWith::Files::TestCase
  context "inside a tmpdir" do
    setup do
      @src_dir = FilePath.tmpdir
      @dst_dir = FilePath.tmpdir
      assert_empty_directory @src_dir
      assert_empty_directory @dst_dir
    end
    
    teardown do
      @src_dir.rm
      @dst_dir.rm
      assert_not_directory @src_dir
      assert_not_directory @dst_dir
    end
    
    context "with a source file" do
      setup do
        @src_file = @src_dir.join( "file.txt" )
        @src_file.write( "Hello world" )
        
        assert_file_not_empty( @src_file )
      end
      
      
      should "successfully move a file into a directory" do
        dest = @dst_dir.join( "file.txt" )
        @src_file.move @dst_dir
        
        assert_file( dest )
      end
      
      
      should "fail to move a file to a non-existent directory" do
        flunk "this actually moves the file (the file getting the name of the 'missing' directory, and I'm not sure that's wrong)"
        not_a_dir = @dst_dir / "humblebrag"
        
        assert_raises( Errno::ENOENT ) do
          @src_file.move( not_a_dir )
        end
      end
      
      should "fail to move a file owing to lack of privileges" do
        write_protected_dir = @dst_dir / "write_protected_dir"
        write_protected_dir.touch_dir
        
        temporarily_write_protect( write_protected_dir ) do
          assert_raises( Errno::EACCES ) do
            @src_file.move( write_protected_dir )
          end
        end
      end
    end
    
      
    
    should "fail to move a non-existent file" do
      f = @src_dir.join( "file.txt" )
      
      assert_no_file( f )
      
      assert_raises( Errno::ENOENT ) do
        f.move( @dst_dir )
      end
    end
  end
    
  #
  #   should "successfully move a directory" do
  #     flunk "write test"
  #   end
  #
  #   should "fail to move a non-existent directory" do
  #     flunk "write test"
  #   end
  #
  #   should "fail to move a directory to a non-existent directory" do
  #     flunk "write test"
  #   end
  #
  #   should "fail to move a directory owing to lack of privileges" do
  #
  #     flunk "write test"
  #   end
  # end
  
  def temporarily_write_protect( f, &block )
    f.chmod( "a-x" )
    yield
    f.chmod( "a+x")
  end
end