require 'helper'

puts "got here"
class TestFilePath < FunWith::Files::TestCase
  context "testing basics" do
    setup do
      
    end
    
    should "initialize kindly" do
      f1 = FilePath.new( "/", "bin", "bash" )
      f2 = "/".fwf_filepath( "bin", "bash" )
      assert f1.exist?
      assert f2.exist?
    end

    should "go up/down when asked" do
      f1 = FilePath.new( "/", "home", "users", "monkeylips", "ask_for_floyd" )
      f2 = FilePath.new( "/", "home", "users" )
      root = FilePath.new( "/" )
      
      assert_equal f2, f1.up.up
      assert_equal root, f1.up.up.up.up.up.up.up
      
      #invoking up didn't change original
      assert_match /ask_for_floyd/, f1.to_s
      
      assert_equal f1, f2.down( "monkeylips" ).down( "ask_for_floyd" )
      assert_equal f1, f2.down( "monkeylips", "ask_for_floyd" )
      
      #invoking down didn't change original
      assert_no_match /ask_for_floyd/, f2.to_s
    end
    
    should "convert from string" do
      str = "/"
      f1 = FilePath.new(str)
      f2 = str.fwf_filepath
      
      assert_equal f1, f2
    end
    
    should "convert from pathname" do
      str = "/"
      f1 = FilePath.new(str)
      f2 = Pathname.new(str).fwf_filepath
      
      assert_equal f1, f2
      
      f3 = f1.join( "bin", "bash" )
      f4 = Pathname.new( str ).fwf_filepath( "bin", "bash" )
      
      assert_equal f3, f4
    end
  end
  
  context "test glob" do
    setup do
      @data_dir = FunWith::Files.root( 'test', 'data' )
    end
    
    should "glob items in test/data directory" do
      files = @data_dir.glob(:all)
      assert_equal 5, files.length
      files = @data_dir.glob(:all, :flags => [File::FNM_DOTMATCH])
      assert_equal 9, files.length
    end
    
    should "glob with case insensitive flag" do
      files = @data_dir.glob("grep1.txt")
      assert_equal 1, files.length
      
      # TODO: Case sensitive search?
      # files = @data_dir.glob("grep1.txt", :flags => [File::FNM_CASEFOLD])
      # assert_equal 2, files.length
      # files = @data_dir.glob("grep1.txt", :sensitive => true)
      # assert_equal 2, files.length
    end
  end
  
  context "test sequence" do
    setup do
      @tmp_dir = FunWith::Files.root( 'test', 'tmp' )
    end
    
    teardown do
      `rm -rf #{@tmp_dir.join('*')}`
    end
    
    should "sequence files nicely" do
      seqfile = @tmp_dir.join("sequence.txt")
      
      10.times do |i|
        seqfile.write( i.to_s )
        seqfile = seqfile.succ
      end
      
      assert @tmp_dir.join("sequence.txt").exist?
      assert @tmp_dir.join("sequence.000000.txt").exist?
      assert @tmp_dir.join("sequence.000008.txt").exist?
      
      assert_equal "0", @tmp_dir.join("sequence.txt").read
      assert_equal "9", @tmp_dir.join("sequence.000008.txt").read
    end
    
    should "sequence files with custom stamp length" do
      seqfile = @tmp_dir.join("sequence.txt")
      
      10.times do |i|
        seqfile.write( i.to_s )
        seqfile = seqfile.succ( digit_count: 4 )
      end
      
      assert @tmp_dir.join("sequence.txt").exist?
      assert @tmp_dir.join("sequence.0000.txt").exist?
      assert @tmp_dir.join("sequence.0008.txt").exist?
      
      assert_equal "0", @tmp_dir.join("sequence.txt").read
      assert_equal "9", @tmp_dir.join("sequence.0008.txt").read
    end
    
    should "sequence files with datestamps" do
      seqfile = @tmp_dir.join("sequence.txt")
      
      10.times do |i|
        seqfile.write( i.to_s )
        seqfile = seqfile.succ( timestamp: true )
        sleep(0.002)
      end
      
      files = seqfile.succession( timestamp: true )
      assert files.length == 10
      
      files.each_with_index do |file, i|
        assert file.exist?
        assert_equal i.to_s, file.read
      end
      
      file_name_strings = files.map(&:to_s)
      assert_equal file_name_strings[1..-1], file_name_strings[1..-1].sort
    end
  end
  
  context "test specify()" do
    should "just friggin' work" do
      fil = "resume.doc".fwf_filepath
      
      test_data = [ [:cyberdyne, "resume.cyberdyne.doc"],
                    [:administrative, "resume.cyberdyne.administrative.doc"],
                    [:v2, "resume.cyberdyne.administrative.v2.doc"],
                    [:gratuitous_use_of_specifier, "resume.cyberdyne.administrative.v2.gratuitous_use_of_specifier.doc"]
                  ]
      
      for key, result in test_data
        fil = fil.specifier( key )
        assert_equal result, fil.to_s
      end
    end
  end
  
  context "test digest functions" do
    setup do
      @tmp_dir = FunWith::Files.root( 'test', 'tmp' )
    end
    
    teardown do
      `rm -rf #{@tmp_dir.join('*')}`
    end
    
    should "md5hash a file" do
      nilhash     = "d41d8cd98f00b204e9800998ecf8427e"
      nilhashhash = "74be16979710d4c4e7c6647856088456" 
      
      empty = @tmp_dir.join("empty.dat")
      empty.touch
      assert_equal( nilhash, empty.md5 )
      
      file = @tmp_dir.join( "#{nilhash}.dat" )
      file.write( nilhash )
      assert_equal( nilhashhash, file.md5 )
    end
  end
end