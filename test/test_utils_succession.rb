require 'helper'

class TestUtilsSuccession < FunWith::Files::TestCase
  USucc = FunWith::Files::Utils::Succession
  
  context "testing Succession.get_successor_name()" do
    should "succeed" do
      with_digit_count( 4 ) do
        assert_succession "file.0001.txt", "file.0002.txt" 
        assert_succession "file.txt", "file.0000.txt" 
        assert_succession "", "0000"
      end
    end
  end
  
  def with_digit_count( i, &block )
    @digit_count = i
    yield 
  end
  
  def assert_succession( input, expected )
    if defined?( @digit_count )
      actual = USucc.get_successor_name( input, @digit_count )
    else
      actual = USucc.get_successor_name( input )
    end
    
    assert_equal( expected, actual, "Utils::Succession.get_successor_name() failed:\n\tinput: #{input}(#{input.class})\n\texpected: #{expected}(#{expected.class})\n\tactual: #{actual}(#{actual.class})")
  end
end