module FunWith
  module Testing
    class TestFwfAssertions < FunWith::Testing::AssertionsTestCase
      context "testing assertions" do
        setup do
          extended_test_case  # sets @case, which is used to access to assertions
          @case_class.install_fun_with_files_assertions
        end
        
        context "testing :assert_fwf_filepath()" do
          should "pass all tests" do
            testing_method :assert_fwf_filepath do
              nope __FILE__
              yep  __FILE__.fwf_filepath
              
              nope nil
              nope :five
              nope 5
              nope [5]
              nope "five"
            end
          end
        end
          
        context "testing :assert_file()" do
          should "pass all tests" do
            testing_method :assert_file do
              yep  __FILE__.fwf_filepath
              
              nope __FILE__
              nope nil
              nope :five
              nope 5
              nope [5]
              nope "five"
            end
          end
        end
        
        context "testing :assert_directory()" do
          should "pass all tests" do
            testing_method :assert_directory do
              nope __FILE__
              nope __FILE__.fwf_filepath
              
              yep  __FILE__.fwf_filepath.dirname
              yep  __FILE__.fwf_filepath.up
              yep  FunWith::Files.root
              
              nope nil
              nope :five
              nope 5
              nope [5]
              nope "five"
            end
          end
        end
      end
    end
  end
end

