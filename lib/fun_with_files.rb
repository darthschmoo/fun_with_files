require 'pathname'  #stdlib
require 'tmpdir'
require "debugger"

for file in %w(file_path root_path remote_path string_extensions pathname_extensions)
  require_relative File.join("files", file)
end

FunWith::Files::RootPath.rootify( FunWith::Files, __FILE__.fwf_filepath.dirname.up )
FunWith::Files::VERSION = FunWith::Files.root("VERSION").read
