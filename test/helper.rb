require 'fun_with_testing'


# begin
#   Bundler.setup(:default, :development)
# rescue Bundler::BundlerError => e
#   $stderr.puts e.message
#   $stderr.puts "Run `bundle install` to install missing gems"
#   exit e.status_code
# end
# 
# require 'test/unit'
# require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'fun_with_files'

# class Test::Unit::TestCase
# end

class FunWith::Files::TestCase < FunWith::Testing::TestCase
  include FunWith::Files
  include FunWith::Files::Errors
  
  
  self.install_fun_with_files_assertions
  # include FunWith::Testing::Assertions::FunWithFiles
  # include FunWith::Testing::Assertions::Basics
  
  def tmpdir( &block )
    if block_given?
      FilePath.tmpdir do |d|
        @tmpdir = d
        yield
      end
    else
      @tmpdir = FilePath.tmpdir      # remember to remove the directory when you're done
    end
  end
  
  def empty_temp_directory
    tmp = FunWith::Files.root( "test", "tmp" )
    tmp.empty!
    assert_directory tmp
    puts tmp.glob(:all)
    assert_empty_directory tmp
  end
  
  def if_internet_works( &block )
    `ping -c 1 google.com 2>&1 >> /dev/null`  # TODO: Portability issue
    connection_detected = $?.success?
      
    if block_given?
      if connection_detected   # TODO:  How to tell difference between "no internet" and "no ping utility?"
        yield
      else
        puts "No internet connection.  Skipping."
      end
    end
  end
end