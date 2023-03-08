require 'helper'

class TestWatchers < FunWith::Files::TestCase
  context "testing Watcher as it benevolently watches over the files placed under its care" do
    setup do
      tmpdir     # assigns @tmpdir a freshly created temp directory
      self.watch @tmpdir
    end
    
    teardown do
      @tmpdir.rm
    end
    
    should "watch an empty directory as a subdirectory and a file are added" do
      @tmpdir.touch_dir :lethe do |d|
        file = d.join( "forgotten_file.txt" )
        file.write( "someone help me remember this" )
        
        get_changes do
          assert_changes :created, d, file
        end
        
        file.append( "\nbecause I don't trust my brain to keep track of things" )
        
        get_changes(1) do
          assert_changes :modified, file
        end
        
        d.rm
      
        get_changes do
          assert_changes :deleted, d, file
        end
      end  
    end
    
    should "watch an empty directory as a bunch of changes happen" do
      @tmpdir.touch_dir( :battles ) do |d0|
        @tmpdir.touch_dir( :bunker_hill ) do |d1|
          file0 = d1.join( "troop_movements.csv" )
          file0.write( "My dearest Sarah,\n\tI fear this may be the last time I write to you.  Our forces are outnumbered." )
          
          get_changes do
            assert_changes :created, d0, d1, file0
          end  
          
          file0.append "Supplies are scarce and the horses have lost their patience with us."
          
          get_changes(1) do
            assert_changes :modified, file0
          end
          
          d1.rm
          
          get_changes(2) do
            assert_changes :deleted, d1, file0
          end
        end
        
        d0.rm
        
        get_changes(1) do
          assert_changes :deleted, d0
        end
      end
    end
    
    should "watch for a file that doesn't exist yet" do
      @tmpdir.touch_dir( "web_app" ) do |d|
        watch( d.join( "restart.txt" ) )
        
        get_changes(0)
        
        restart_file = d.touch( "restart.txt" )
        
        get_changes(1) do
          assert_changes :created, restart_file
        end
        
        restart_file.rm
        
        get_changes(1) do
          assert_changes :deleted, restart_file
        end
        
        get_changes(0)
      end
    end
    
    should "build out a filesystem using DirectoryBuilder" do
      @tmpdir.touch_dir( :ebook ) do |ebook|
        watch ebook
        
        DirectoryBuilder.create( ebook ) do |builder|
          builder.dir( :html ) do
            builder.file "title_page.xhtml", "Make sure we get some neato art to go here."
            builder.file "chapter1.xhtml", "Besta times, worsta times, y'know?"
            builder.file "chapter2.xhtml", "I see a magpie perched on the roof."
          end
          
          builder.dir( :css ) do
            builder.file "main.css", "p{ background-color: painfully-pink}"
            builder.file "title_page.css", "body{ width: 80% }"
          end
          
          builder.dir( :images ) do
            builder.file "cover.png", "We shoulda hired a graphic designer"
          end
        end
        
        html_dir = ebook / :html
        
        images_dir = ebook / :images
        cover_file = images_dir / "cover.png"        
        
        get_changes(9) do 
          assert_changes :created, 
                         #  ebook,      # already existed when the watcher started
                         html_dir, 
                         html_dir / "title_page.xhtml",
                         ebook / :css, 
                         ebook / :css / "main.css",
                         images_dir,
                         cover_file
        end
        
        cover_file.append ", Trevor worked out okay last time, can we use him again?"
        
        # debugger
        
        get_changes(2) do
          assert_changes :modified, cover_file, images_dir, html_dir
        end

        images_dir.rm
        
        get_changes(2) do
          assert_changes :deleted, images_dir, cover_file, html_dir
        end
      end
    end
    
    should "only notice changes that aren't excluded by filters" do
      
      @tmpdir.touch_dir( :application_code ) do |code|
        watch( code )
        
        @watcher.filter( notice: /\.cpp$/, ignore: /main.cpp$/ )

        f0 = code.touch( "main.cpp" )
        f1 = code.touch( "counter.cpp" )
        
        get_changes( count: 1 ) do
          assert_changes :added, f1
        end
      end
    end
  end
  
  def watch( *paths )
    @watcher = Watcher.watch( *paths ).sleep_interval( 0.01 )
  end
  
  def get_changes( count: nil, expected: nil, &block )
    @changes = @watcher.update
    yield if block_given?
    assert_change_count( count ) unless count.nil?
    assert_change_set( expected ) unless expected.nil?
  end
  
  def assert_changes( status, *paths )
    assert_kind_of Hash, @changes
    
    oopsies = {}
    
    for path in paths
      path_to_report = path.relative_path_from(@tmpdir).to_s
      
      if @changes.has_key?( path )
        oopsies[path_to_report] = :change_not_reported
      elsif status != @changes[path]
        oopsies[path_to_report] = { :expected => status, :actual => @changes[path] } 
      end
      
      unless oopsies.fwf_blank?
        assert false, "Unexpected:" + oopsies.inspect
      end
    end
  end
  
  def assert_change_count( i )
    assert defined?( @changes )
    assert_kind_of Hash, @changes
    assert_length i, @changes
  end
end