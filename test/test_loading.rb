require 'helper'

include FunWith::Files

class TestLoading < FunWith::Files::TestCase
  should "require a file" do
    assert !defined?( LoadedOrRequiredModule::Loaded1 ), "LoadedOrRequiredModule::Loaded1 shouldn't be defined yet."
    FunWith::Files.root( "test", "loadable_dir", "dir1", "file1.rb" ).requir
    assert defined?( LoadedOrRequiredModule::Loaded1 ), "LoadedOrRequiredModule::Loaded1 should be defined now."
  end

  should "load a file" do
    assert !defined?( LoadedOrRequiredModule::Loaded2 ), "LoadedOrRequiredModule::Loaded2 shouldn't be defined yet."
    FunWith::Files.root( "test", "loadable_dir", "dir2", "file2.rb" ).load
    assert defined?( LoadedOrRequiredModule::Loaded2 ), "LoadedOrRequiredModule::Loaded2 should be defined now."
  end
  
  should "require a directory" do
    assert !defined?( LoadedOrRequiredModule::Loaded3 ), "LoadedOrRequiredModule::Loaded3 shouldn't be defined yet."
    FunWith::Files.root( "test", "loadable_dir", "dir3" ).requir
    assert defined?( LoadedOrRequiredModule::Loaded3 ), "LoadedOrRequiredModule::Loaded3 should be defined now."
  end
  
  should "load a directory" do
    assert !defined?( LoadedOrRequiredModule::Loaded4 ), "LoadedOrRequiredModule::Loaded4 shouldn't be defined yet."
    FunWith::Files.root( "test", "loadable_dir", "dir4" ).load
    assert defined?( LoadedOrRequiredModule::Loaded4 ), "FunWith::Files::LoadedOrRequiredModule::Loaded4 should be defined now."
  end
end