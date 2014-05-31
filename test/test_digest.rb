require 'helper'

class TestDigest < FunWith::Files::TestCase
  context "inside a tmpdir" do
    setup do
      @dir = FilePath.tmpdir
    end
    
    teardown do
      @dir.rm
      assert_equal false, @dir.directory?
    end
    
    should "digest a blank file" do
      blankfile = @dir.touch('blank.dat')
      assert_empty_file blankfile
      
      results = { :md5    => "d41d8cd98f00b204e9800998ecf8427e",
                  :sha1   => "da39a3ee5e6b4b0d3255bfef95601890afd80709",
                  :sha2   => "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                  :sha256 => "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                  :sha384 => "38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b",
                  :sha512 => "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"
                }
                
      for h in %w(md5 sha1 sha2 sha256 sha384 sha512).map(&:to_sym)
        assert_equal( results[h], blankfile.send(h), "A blank file should have a #{h}() digest of #{results[h]}" )
      end
    end
  end
end