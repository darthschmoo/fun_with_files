require 'helper'

class TestFunWithFiles < FunWith::Files::TestCase
  context "testing basics" do
    should "have fwf_blank?() working" do
      assert [].fwf_blank?
      assert false.fwf_blank?
      assert Hash.new.fwf_blank?
      assert "".fwf_blank?
      assert "    ".fwf_blank?
      refute true.fwf_blank?
      refute Object.new.fwf_blank?
    end

    should "have fwf_present?() working" do
      refute [].fwf_present?
      refute false.fwf_present?
      refute Hash.new.fwf_present?
      refute "".fwf_present?
      refute "    ".fwf_present?
      assert true.fwf_present?
      assert Object.new.fwf_present?
    end
    
    should "respond to api" do
      assert_respond_to( FunWith::Files, :root )
      assert_respond_to( FunWith::Files, :version )
      
      assert_equal "0.0.17", FunWith::Files.version   # Gotta change with every point release.  Ick.
    end
  end
end