require 'helper'

class TestExtensionMethods < FunWith::Files::TestCase
  context "Testing extension methods" do
    setup do
      @bash = "/bin/bash".fwf_filepath
      @log  = "/var/log/apache/access.log".fwf_filepath
      @older_log = "/var/log/apache/access.log.9"
    end

    context "Testing ext?()" do
      should "correctly identify the extension" do
        assert_true @bash.ext?("")
        
        assert_true  @log.ext?(".log")
        assert_true  @log.ext?(:log)
        assert_false @log.ext?(".blog")
        assert_true  @log.ext?(:blog, :flog, :frog, :log)
      end
      
      should "run a block if the extension matches" do
        var = 5
        
        @log.ext?(:log) do |f|
          assert_equal @log, f
          var = 6
        end
        
        assert_equal 6, var
      end
    end
  
    context "Testing file.ext()" do
    
      should "draw a blank on bash file" do
        assert_blank @bash.ext
        assert_equal "", @bash.ext
      end
    
      should "add an extension when an extension is given as an argument" do
        bash2 = @bash.ext( 12 )
      
        assert_fwf_filepath bash2
        assert_equal "12", bash2.ext
      
        for ext in [:exe, "exe"]
          bash2 = @bash.ext( ext )
          assert_fwf_filepath bash2
          assert_equal "exe", bash2.ext
        end
      end
    
      should "add multiple extensions when multiple extensions are given" do
        for args in [ [:tar, :gz], ["tar", "gz"], [".tar", ".gz"] ]
          bash2 = @bash.ext( *args )
          assert_equal "gz", bash2.ext
          assert_equal "/bin/bash.tar.gz", bash2.path
        end
      end
    end
  end
end
