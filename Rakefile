# encoding: utf-8

require 'fun_with_testing'
# require 'rubygems'
# require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'

# require 'juwelier'
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "fun_with_files"
  gem.homepage = "http://github.com/darthschmoo/fun_with_files"
  gem.license = "MIT"
  gem.summary = "A mashup of several File, FileUtils, and Dir class functions, with a peppy, fun-loving syntax"
  gem.description = <<-DESC
  A more intuitive syntax for performing a variety of file actions. Examples:
    "/".fwf_filepath.join('usr', 'bin', 'bash').touch
    FunWith::Files::FilePath.home("Music").glob(:ext => "mp3", :recurse => true)
    home = FunWith::Files::FilePath.home
    home.touch( "Music", "CDs", "BubbleBoyTechnoRemixxxx2011", "01-jiggypalooza.mp3" )
    home.touch_dir( "Music", "CDs", "ReggaeSmackdown2008" ) do |dir|
      dir.touch( "liner_notes.txt" )
      dir.touch( "cover.jpg" )
      dir.touch( "01-tokin_by_the_sea.mp3" )
      dir.touch( "02-tourists_be_crazy_mon.mp3" )
    end
DESC
  gem.email = "keeputahweird@gmail.com"
  gem.authors = ["Bryce Anderson"]
  # dependencies defined in Gemfile
  
  
  gem.files = Dir.glob( File.join( ".", "*.rb" ) ) + 
              Dir.glob( File.join( ".", "lib", "**", "*.rb" ) ) + 
              Dir.glob( File.join( ".", "test", "**", "*" ) ) +
              [ "Gemfile", 
                "Rakefile", 
                "LICENSE.txt", 
                "README.rdoc",
                "VERSION",
              ]
end

Juwelier::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

# require 'rcov/rcovtask'
# Rcov::RcovTask.new do |test|
#   test.libs << 'test'
#   test.pattern = 'test/**/test_*.rb'
#   test.verbose = true
#   test.rcov_opts << '--exclude "gems/*"'
# end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "fun_with_files #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
