# require 'rubygems'
# require 'bundler'
# require 'debugger'
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
  include FunWith::Testing::Assertions::FunWithFiles
  include FunWith::Testing::Assertions::Basics
  
  def tmpdir( &block )
    FilePath.tmpdir do |d|
      @tmpdir = d
      yield
    end
  end
  
  def empty_temp_directory
    tmp = FunWith::Files.root("test", "tmp")
    tmp.empty!
    assert_directory tmp
    puts tmp.glob(:all)
    assert_empty_directory tmp
  end
end