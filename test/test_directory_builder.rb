require 'helper'

class TestDirectoryBuilder < FunWith::Files::TestCase
  context "tearing my hair out because shoulda seems borked" do
    should "stop blaming shoulda for my problems" do
      assert true
    end
  
    should "realize that assert statements need to be inside should blocks" do
      assert "Okay, okay.  I get it.  Now lay off me."
    end
  
    should "figure out why the hell [].is_a?(Array) returns false" do
      assert_kind_of Array, []
      assert [].is_a?(Array)
    end
  end
  
  context "In a temporary directory" do
    should "create a temporary directory" do
      DirectoryBuilder.tmpdir do |b|
        assert_equal DirectoryBuilder, b.class    # 
        assert b.current_path.exist?
      end
    end
  
    should "write data to a new file" do
      DirectoryBuilder.tmpdir do |b|
        assert_equal DirectoryBuilder, b.class
        assert b.current_path
        assert b.current_path.exist?
        b.file("widdershins.txt") do |f|
          f << "Hello World"
          f.flush
        
          assert b.current_file.exist?
          assert_equal 11, b.current_file.size
        end
      end
    end
  
    should "copy files from elsewhere into the directory" do
      DirectoryBuilder.tmpdir do |b|
        assert_equal DirectoryBuilder, b.class
        src = FunWith::Files.root.join("Gemfile")
        assert src.exist?
      
        b.copy( FunWith::Files.root.join("Gemfile") )
          
        gemfile = b.current_path.join("Gemfile")
        assert gemfile.exist?
        assert !gemfile.zero?
        assert_equal 1, gemfile.grep( /jeweler/ ).length
      end
    end
  
    should "copy files from elsewhere, renaming the file in the destination" do
      DirectoryBuilder.tmpdir do |b|
        assert_equal DirectoryBuilder, b.class
        assert !b.current_path.join("helpers.rb").exist?
        b.copy( FunWith::Files.root("lib", "fun_with_files.rb"), "fwf.rb" )
        assert b.current_path.join("fwf.rb").exist?
      end
    end
    
    should "download random crap from all over the Internet" do
      if_internet_works do
        DirectoryBuilder.tmpdir do |b|
          gist_url = "http://bannedsorcery.com/downloads/testfile.txt"
          gist_text = "This is a file\n==============\n\n**silent**: But _bold_! [Link](http://slashdot.org)\n"
          b.download( gist_url, "gist.txt" )
        
          b.file( "gist.txt.2" ) do
            b.download( gist_url )
          end
        
          assert b.current_file.nil?
          assert b.current_path.join("gist.txt").exist?
          assert b.current_path.join("gist.txt.2").exist?
          assert_equal gist_text, b.current_path.join("gist.txt").read
        end
      end
    end
  
    should "exercise all manner of features to create a complex directory" do
      DirectoryBuilder.tmpdir do |b|
        assert_equal DirectoryBuilder, b.class
        root = FunWith::Files.root
        gemfile = root.join("Gemfile")
        b.copy( gemfile )
        assert gemfile.exist?
        assert_equal gemfile.size, b.current_path.join("Gemfile").size
        
        b.dir( "earth" ) do
          b.dir( "air") do
            b.dir( "fire" ) do
              b.dir( "water" ) do
                b.file( "hello.txt" )
                b.file << "H"
                b.file << "e"
                b.file << "l"
                b.file << "l"
                b.file << "o"
              end
              
              assert b.current_file.nil?
            end
          end
        end
        
        assert "Hello", b.current_path.join("earth", "air", "fire", "water", "hello.txt").read
        
        b.dir( "fire", "water", "earth", "air" ) do
          assert b.current_path.exist?
          b.copy( FunWith::Files.root.join("Gemfile"), "Gemfile.example" )
          b.copy( FunWith::Files.root.join("Gemfile.lock"), "Gemfile.lock.example" )
          b.copy( FunWith::Files.root.join("Rakefile"), "Rakefile" )
          
          for file in %W(Gemfile.example Gemfile.lock.example Rakefile)
            assert b.current_path.join(file).exist?, "#{file} should exist"
          end
        end
        
        directory = ["air", "earth", "water", "fire"]
        b.dir( *directory ) do
          b.file( "slipstream.txt", "file contents" )
        end
        
        assert b.current_path.join(*directory).exist?
        slip = b.current_path.join(*directory).join("slipstream.txt")
        assert slip.exist?
        assert_equal false, slip.empty?
        assert_equal "file contents", b.current_path.join(*directory).join( "slipstream.txt" ).read
        
      end
    end
  end
end
