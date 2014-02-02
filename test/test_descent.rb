require 'helper'

class TestDescent < FunWith::Files::TestCase
  should "descend and ascend" do
    root = FunWith::Files.root
    
    ascent = []
    descent = []
    
    FunWith::Files.root.ascend do |path|
      ascent << path
    end
    
    FunWith::Files.root.descend do |path|
      descent << path
    end

    assert_equal ascent, descent.reverse
    assert_equal ascent[1], ascent[0].up
  end
end