require 'helper'

class TestFilePath < FunWith::Files::TestCase
  context "testing basics" do
    should "initialize kindly" do
      f1 = FilePath.new( "/", "bin", "bash" )
      f2 = "/".fwf_filepath( "bin", "bash" )
      assert_file f1
      assert_file f2
    end
    
    should "have location class methods available" do
      assert_respond_to( FunWith::Files::FilePath, :home )
      assert_respond_to( FunWith::Files::FilePath, :config_dir )
      assert_respond_to( FunWith::Files::FilePath, :root )
      assert_respond_to( FunWith::Files::FilePath, :data_dir )
    end
    
    
    should "join smoothly" do
      bin_dir = "/bin".fwf_filepath
      assert_equal( "/bin/bash", bin_dir.join("bash").to_s )
      assert_equal( "/bin/bash", bin_dir.join("bash".fwf_filepath).to_s )
    end

    should "go up/down when asked" do
      f1 = FilePath.new( "/", "home", "users", "monkeylips", "ask_for_floyd" )
      f2 = FilePath.new( "/", "home", "users" )
      root = FilePath.new( "/" )
      
      assert_equal f2, f1.up.up
      assert_equal root, f1.up.up.up.up.up.up.up
      
      #invoking up didn't change original
      assert_match( /ask_for_floyd/, f1.to_s )
      
      assert_equal f1, f2.down( "monkeylips" ).down( "ask_for_floyd" )
      assert_equal f1, f2.down( "monkeylips", "ask_for_floyd" )
      
      # invoking down didn't change original
      refute_match( /ask_for_floyd/, f2.to_s )
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
      
      assert_file @tmp_dir.join("sequence.txt")
      assert_file @tmp_dir.join("sequence.000000.txt")
      assert_file @tmp_dir.join("sequence.000008.txt")
      
      assert_file_contents @tmp_dir.join("sequence.txt"), "0"
      assert_file_contents @tmp_dir.join("sequence.000008.txt"), "9"
    end
    
    should "sequence files with custom stamp length" do
      seqfile = @tmp_dir.join("sequence.txt")
      
      10.times do |i|
        seqfile.write( i.to_s )
        seqfile = seqfile.succ( digit_count: 4 )
      end
      
      assert_file @tmp_dir.join("sequence.txt")
      assert_file @tmp_dir.join("sequence.0000.txt")
      assert_file @tmp_dir.join("sequence.0008.txt")
      
      assert_file_contents @tmp_dir.join("sequence.txt"), "0"
      assert_file_contents @tmp_dir.join("sequence.0008.txt"), "9"
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
        assert_file file
        assert_file_contents file, i.to_s
      end
      
      file_name_strings = files.map(&:to_s)
      assert_equal file_name_strings[1..-1], file_name_strings[1..-1].sort
    end

    should "timestamp files using the timestamp() method" do
      timestampable_file = @tmp_dir.join( "timestamped.dat" )
      timestamped_file1  = timestampable_file.timestamp
      timestamped_file2  = timestampable_file.timestamp("%Y")

      assert timestamped_file1 =~ /timestamped.\d{17}.dat$/
      assert timestamped_file2 =~ /timestamped.\d{4}.dat$/
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
      empty_temp_directory
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

  context "test access" do
    should "receive an electric shock when it tries to touch an unwritable file" do
      @read_only_file = "/bin/bash".fwf_filepath   # This usually exists. I don't know enough Windows to think of a similarly ubiquitous file.
      
      if @read_only_file.file? && ! @read_only_file.writable?
        assert_raises( Errno::EPERM ) do
          @read_only_file.touch
        end
      else
        skip
      end
    end
  end
  
  context "testing extension methods" do
    setup do
      @hello_path = "hello.txt".fwf_filepath
      @dot_path0 = ".config".fwf_filepath
      @dot_path1 = "~/.ssh".fwf_filepath
    end
    
    context "test ext()" do
    
      should "not change path when sent nil as an argument" do
        assert_equal @hello_path.path, @hello_path.ext( nil ).path
      end
    
      should "append when given symbol" do
        assert_equal @hello_path.path + ".tgz", @hello_path.ext( :tgz ).path
      end
    
      should "append when given string" do
        assert_equal @hello_path.path + ".tgz", @hello_path.ext( 'tgz' ).path
      end
    
      should "append correctly when given leading ." do
        assert_equal @hello_path.path + ".tgz", @hello_path.ext( '.tgz' ).path
      end
    
      should "append multiple extensions as separate args" do
        assert_equal @hello_path.path + ".backup.tar.gz", @hello_path.ext( :backup, "tar", nil, ".gz" ).path
      end
    
      should "append multiple extensions as a single string" do
        assert_equal @hello_path.path + ".backup.tar.gz", @hello_path.ext( ".backup.tar.gz" ).path
      end
    end
    
    context "test without_ext()" do
      setup do

      end
      
      should "pop the extension (normal)" do
        #debugger
        assert_equal "hello", @hello_path.without_ext.to_s
        assert_equal "hello", @hello_path.without_ext("txt").path
        assert_equal "hello", @hello_path.without_ext(".txt").path
        assert_equal "hello.txt", @hello_path.without_ext(".html").path
        assert_equal "hello.txt", @hello_path.without_ext("html").path
        
        assert_equal "hello", @hello_path.without_ext(:txt).path
      end
      
      should "not affect dot files" do
        assert_equal ".config", @dot_path0.without_ext.path
        assert_equal ".config", @dot_path0.without_ext("config").path
        assert_equal ".config", @dot_path0.without_ext(".config").path
        assert_equal ".config", @dot_path0.without_ext(:config).path
      end
    end
    
    # Why does it return a filepath for the dirname piece, strings for the other two pieces?
    context "test dirname_and_basename_and_ext" do
    end
  end
  
  context "test join()" do
    setup do 
      @path = "/".fwf_filepath
    end
    
    should "accept all manner of arguments" do
      expected = "/bin/0/file.rb".fwf_filepath
      result = @path.join( :bin, 0, "file.rb" )
      
      assert_equal expected, result
      
      result = @path / :bin / 0 / "file.rb"
      assert_equal expected, result
    end
  end
end