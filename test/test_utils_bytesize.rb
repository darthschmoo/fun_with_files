require 'helper'

class TestUtilsByteSize < FunWith::Files::TestCase
  context "testing the thing" do
    setup do
      @bytie = Object.new
      @bytie.extend FunWith::Files::Utils::ByteSize
    end
    
    should "respond to :to_bytes" do
      assert_respond_to @bytie, :to_bytes
    end
    
    should "accurately convert strings to bytes" do
      assert_bytes 1_000, "1000b"
      assert_bytes 1_000, "1 kb"
      assert_bytes 1_000, "0.001 MB"
      assert_bytes 1_000, "0.000001 GB"
      
      assert_bytes 1_234, "1234"
      assert_bytes 1_234, "  1.234  kb  "
      assert_bytes 9_001, "9.001k"                    # it's over 9000!
    end
    
    context "converting expressions between units" do
      should "handle simple cases" do
        assert_converts "1KB", "B",  "1000B"
        assert_converts "2MB", "KB", "2000KB"
        assert_converts "3GB", "MB", "3000MB"
        assert_converts "4TB", "GB", "4000GB"
        assert_converts "5PB", "TB", "5000TB"
      end
    
      should "be case insensitive" do
        assert_converts "1kb", "B", "1000B"
        assert_converts "1000k", "mb", "1mb"
        assert_converts "1000m", "GB", "1GB"
        assert_converts "2000 PB", " EB", "2 EB"
      end

      should "sometimes put space between number and unit" do
        assert_converts "2000 PB", " EB", "2 EB"
      end
      
      should "reflect the unit styling that the caller sends" do
        assert_converts "1kb", "b", "1000b"     # uses the unit capitalization that the caller sends
      end
      
      should "sometimes use decimal points" do
        assert_converts "900kb", "MB", "0.9MB"
        assert_converts "930kb", "mb", "0.9mb"
      
        assert_converts "99500b", "kb", "99.5kb"
        assert_converts "1200MB", "gb", "1.2gb"
      end
      
      should "sometimes not use decimal points" do
        assert_converts "100372b", "k", "100k"
        assert_converts "1b", "GB", "0GB"
      end
    end
  end
  
  def assert_bytes( n, expr )
    assert_equal n, @bytie.to_bytes( expr ), "to_bytes( #{expr} ) should resolve to #{n}"
  end
  
  def assert_converts( old_expr, new_units, new_expr )
    assert_equal new_expr, @bytie.convert( old_expr, new_units )
  end
end