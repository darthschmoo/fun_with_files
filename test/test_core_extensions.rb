require 'helper'

class TestCoreExtensions < FunWith::Files::TestCase
  context "testing hash" do
    should "fwf_reverse_merge nicely" do
      h = { "1" => 1, "2" => 2 }.fwf_reverse_merge( "3" => 3, "1" => 0 )
      
      assert_equal 1, h["1"]
      assert_equal 2, h["2"]
      assert_equal 3, h["3"]
      
      h.fwf_reverse_merge!( "1" => "one", "2" => "two", "3" => "three" )
      
      assert_equal 1, h["1"]
      assert_equal 2, h["2"]
      assert_equal 3, h["3"]
      
      h.fwf_reverse_merge!( "1" => "one", "2" => "two", "3" => "three", "4" => "four" )

      assert_equal 1, h["1"]
      assert_equal 2, h["2"]
      assert_equal 3, h["3"]
      assert_equal "four", h["4"]
    end
    
    should "fwf_blank? nicely." do
      assert_equal false, { 1 => 2 }.fwf_blank?
      assert_equal true, {}.fwf_blank?
      assert_equal true, true.fwf_present?
    end
  end
end
