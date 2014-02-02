require 'pathname'  #stdlib
require 'tmpdir'
require 'debugger'

for file in %w(directory_builder
               downloader
               file_orderer
               file_path 
               root_path 
               remote_path 
               string_extensions 
               string_behavior 
               pathname_extensions 
               xdg_extensions)
               
  require_relative File.join("files", file)
end

FunWith::Files::RootPath.rootify( FunWith::Files, __FILE__.fwf_filepath.dirname.up )
FunWith::Files::VERSION = FunWith::Files.root("VERSION").read

FunWith::Files::FilePath.send( :include, FunWith::Files::StringBehavior )