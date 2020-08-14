# fun_with_files #

FunWith::Files adds a bit of whimsy to your file manipulations, if that's what you're looking for.

To the code!

    require 'fun_with_files'
    
    include FunWith::Files
    
    class Project; end
    
    RootPath.rootify( Project, "/home/user/path/to/project" )
    
    Project.root  # => <FunWith::Files::FilePath:/home/user/path/to/project>
    Project.root("hello", "subdir") # => <FunWith::Files::FilePath:/home/user/path/to/project/hello/subdir>
    
    home = FilePath.home
    music = FilePath.home( "Music" )
    
    music.touch_dir( "sinead_o_connor" ) do |dir|
      dir.touch_dir( "sean_nos_nua" ) do |subdir|
        subdir.touch( "03-lord_franklin.mp3" )
      end
      
      dir.touch_dir( "theology" ) do |subdir|
        subdir.touch( "05-darker_than_blue.mp3" )
      end
    end
    
    mp3s = music.glob( "**/*.mp3" ) # => [<FunWith::Files::FilePath:/home/user/Music/sinead_o_connor/sean_nos_nua/03-lord_franklin.mp3>,
                            # <FunWith::Files::FilePath:/home/user/Music/sinead_o_connor/theology/05-darker_than_blue.mp3>]
    mp3s.last.write( Hypothetical::MP3::Source.new.read )
    
    # whole buchcha other goodies, yet to be documented.
    


### Linking files ###

While fwf.symlink and fwf.link are both backed by FileUtils.ln / FileUtils.ln_s, the defaults are somewhat different



## DirectoryBuilder ##

DirectoryBuilder is a class for defining and populating a file hierarchy with relative ease.  DirectoryBuilder is probably most easily demonstrated by example.  Sample code:

    # starts by creating directory.  If parent directories don't exist, they will soon.
    DirectoryBuilder.create( '~/project' ) do |b|
      b.dir("images") do                      # creates subdirectory "images", which gets populated within the block
        for img in src_dir.entries.select{|img| img.extension == ".png"}
        b.copy( src_dir.join( img.filename ) )         # copies a bunch of files from another directory
      end    # rises back to the initial '~/project directory

      b.copy( src_dir.join( "rorshach.xml" ) )                  # Copies a file from a source file.
      b.download( "dest.bash", "http://get.rvm.io" )            # downloads file directly beneath '~/project'
                                                                # maybe someday, though

      b.dir("text", "scenes") do   # creates ~/project/text/scenes subdir (creating two new directories text/ and text/scene/)
        b.file( "adventure_time.txt" ) do |f|
          f << "Fill this in later"             # text is written to the file
        end

        # calling .file without feeding it a block leaves it open for writing,
        # until either the enclosing block terminates, or b.file is called again 
        # with a filename argument.  While it's open, b.file can be treated like
        # any IO object.
        b.file( "another_brick.txt" )           
        b.file << "Hey, you!"
        b.file << "Yes, you!"
        b.file.push "Stand still, laddie!"


        # TODO: Make sure this works.
        #
        # Set a bunch of vars to apply to the template.  Template gets copied into DirectoryBuilder's current
        # directory, with the template's filename (minus the .template extension).
        #
        # Inside the templates, you can use Ruby code in the usual ERB style.  The vars you declare will be
        # available within the template as (see example below) @fname, @lname, @graduated, etc.
        #
        # See FunWith::Templates for a better understanding of templates.  You must require the 'fun_with_templates'
        # gem to use the template function.
        b.template( templates_dir.join("blue_template.txt.template") ) do |t|
          # t is a VarCollector, which is just a hash with a couple of added methods, shown here.
          # I recommend sticking to t.var and t.vars for setting variables, in case the interface
          # changes.
          t.var(:fname, "John")      
          t.vars(graduated: "2003", blackmailed: "2004")   # set multiple variables at a time
          t[:lname] = "Macey"
          t.var(:state, "Ohio")
          t.vars(quot: "That wasn't my duck.", photo: "john.png", css: "font-family: arial")
        end

        b.copy( [src_dir.join("abba.txt"), "baab.txt"] )  # contents of abba.txt copied into baab.txt


        b.file( ".lockfile" )   # creates an empty file, closing it to further writing at the end of the block.
      end
    end
  
  

    


## Contributing to fun_with_files ##

Boilerplate from Juwelier, but seems to make sense.

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright ##

Copyright (c) 2020 Bryce Anderson. See LICENSE.txt for further details.

