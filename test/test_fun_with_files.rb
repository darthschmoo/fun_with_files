require 'helper'

class TestFunWithFiles < FunWith::Files::TestCase
  context "testing basics" do
    should "have core extensions working" do
      assert [].fwf_blank?
      assert false.fwf_blank?
      assert Hash.new.fwf_blank?
      assert "".fwf_blank?
      assert "    ".fwf_blank?
      refute true.fwf_blank?
      refute Object.new.fwf_blank?
    end
  end
end