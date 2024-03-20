require 'helper'

class TestTimestamping < FunWith::Files::TestCase
  context "testing timestamping" do
    setup do
      @tmp_dir = FunWith::Files.root( 'test', 'tmp' )
      @logfile = @tmp_dir / "apache.log"
      @stamp_time = Time.new( 2000, 10, 13, 23, 59, 59 )
    end
  
    teardown do
      `rm -rf #{@tmp_dir.join('*')}`
    end
    
    should "sequence files with datestamps" do
      dates = %w(2012-11-30 1900-12-01 2727-06-14)
      
      for date in dates
        d = Date.new( * date.split("-").map(&:to_i) )
        
        f = @logfile.timestamp( format: :ymd, time: d )
        f.write( date )
        
        fy = @logfile.timestamp( format: :y, time: d )
        fy.write date[0..3]
      end
      
      for str in dates + %w(2012 1900 2727)
        file = @tmp_dir / "apache.#{str}.log"
        assert_file file
        assert_file_contents file, str
      end
    end

    should "timestamp files using the timestamp() method" do
      timestampable_file = @tmp_dir / "timestamped.dat"
      
      timestamped_file1  = timestampable_file.timestamp
      timestamped_file2  = timestampable_file.timestamp( format: :y )

      assert timestamped_file1 =~ /timestamped.\d{17}.dat$/
      assert timestamped_file2 =~ /timestamped.\d{4}.dat$/
    end
    
    should "raise an error when invalid format requested" do
      f = @tmp_dir / "apache.log"
      
      stamped = f.timestamp
      
      assert_raises Errors::TimestampFormatUnrecognized do
        f.timestamp( format: :zztop )
      end
      
      # Symbols only!
      assert_raises Errors::TimestampFormatUnrecognized do
        f.timestamp( format: "ymd" )
      end
    end
    
    should "update the timestamp of a file that already has one" do
      f = "apache.19931020235959000.tgz".fwf_filepath
      timestamped_file = f.timestamp( time: @stamp_time )
      
      assert_equal "apache.20001013235959000.tgz", timestamped_file.path
    end
    
    should "be able to give the timestamp method a custom format" do
      fmt = Utils::TimestampFormat.new.recognizer( /^\d{2}_\d{2}_\d{2}$/ ).strftime( "%m_%d_%y" )
      
      timestamped_file = @logfile.timestamp( format: fmt, time: @stamp_time )
      assert_equal "apache.10_13_00.log", timestamped_file.basename.path
    end
  end
end
