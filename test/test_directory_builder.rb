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
          assert_empty_file( f.fwf_filepath )
          
          f << "Hello World"
          f.flush
          
          fil = b.current_file.fwf_filepath
          assert_file_not_empty fil
          assert_equal 11, fil.size
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
        assert_equal 1, gemfile.grep( /fun_with_testing/ ).length
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
          # The file Bryce uses on Github to prove to Keybase that he owns this Github account
          # I used to host a test file on my own site, but apparently if you stop paying DigitalOcean 
          # for a few measly months your website goes away.  Github will probably provide a more
          # stable target.
          url = "https://gist.githubusercontent.com/darthschmoo/ac3ca60338ed41e87b94448f9e851fd3/raw" + 
                "/3cba6b60b552266f4d5aa92d307ef2cda0cf228b/fun_with_files.download.txt"
                
          dest_file  = "download.01.txt"
          dest_file2 = "download.02.txt"
          
          downloaded_text        = "You have successfully downloaded a file.  Huzzah!"
          downloaded_text_md5    = "2e9d3a924ea36c860c3dd491166ec1ce"
          downloaded_text_sha1   = "d9be1d5b5c8bd1de6b1dcb99e02cab8e35ed9659"
          downloaded_text_sha256 = "dc9a6e5d571b39b9754b9592a3b586db8186121d37ec72f7fcbf45241cc43aa6"

          b.download( url, dest_file, 
                      :md5    => downloaded_text_md5,
                      :sha1   => downloaded_text_sha1,
                      :sha256 => downloaded_text_sha256
          )
          
        
          b.file( dest_file2 ) do
            b.download( url )
          end
        
          assert b.current_file.nil?
          assert b.current_path.join( dest_file ).exist?
          assert b.current_path.join( dest_file2 ).exist?
          assert_equal downloaded_text, b.current_path.join( dest_file ).read
          assert_equal downloaded_text, b.current_path.join( dest_file2 ).read
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
        
        assert_equal "Hello", b.current_path.join("earth", "air", "fire", "water", "hello.txt").read
        
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
