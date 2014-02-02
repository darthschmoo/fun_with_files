require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'fun_with_files'

class Test::Unit::TestCase
end

class FunWith::Files::TestCase < Test::Unit::TestCase
  include FunWith::Files
  
  def tmpdir( &block )
    FunWith::Files::FilePath.tmpdir do |d|
      @tmpdir = d
      yield
    end
  end
end