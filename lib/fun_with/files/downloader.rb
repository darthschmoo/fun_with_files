require 'open-uri'            # needed by Utils::Downloader
require 'net/http'
require 'net/https'
require 'openssl'
require 'timeout'


module FunWith
  module Files
    class Downloader
      def self.download( *args )
        self.new.download( *args )
      end
      
      # stolen from:
      # http://stackoverflow.com/questions/2263540/how-do-i-download-a-binary-file-over-http-using-ruby
      
      # options:
      #    :md5 => <digest>  :  Running md5 on the downloaded file should result in an error
      #    :sha256 => <digest> : 
      def download( url, io, opts = {} )
        @uri = URI.parse( url )
        @io  = io

        URI.open( url ) do |f|
          @io << f.read
        end
        
        io_path = @io.fwf_filepath
        
        if io_path.file?
          if io_path.valid_digest?( opts )
            true
          else
            warn( "File may not have downloaded correctly, or is validating against a bad hash #{io_path} #{opts.inspect}")
            false
          
          end
        else
          warn( "File did not download correctly, or was deleted: #{io_path}")
          false
        end
        
        # @io << Net::HTTP.get( @uri )

        # Net::HTTP.start( @uri.host, @uri.port ) do |http| 
        #   http.request_get( @uri.path ) do |request| 
        #     request.read_body do |seg|
        #       puts "==============================  #{seg} ============================="
        #       io << seg
        #       #hack -- adjust to suit:
        #       sleep 0.005 
        #     end
        #   end
        # end
        
        
        
        
      rescue StandardError => e
        handle_network_errors( e )
      end

      def handle_network_errors( e )
        raise e
      rescue URI::InvalidURIError => e
        puts "Tried to get #{@uri.path} but failed with URI::InvalidURIError."
      rescue OpenURI::HTTPError => e
        STDERR.write( "Couldn't fetch podcast info from #{@uri.path}\n" )
        STDERR.write( "#{e}\n\n" )
      rescue SocketError => e
        STDERR.write( "Problem connecting to server (Socket error) when downloading #{@uri.path}." )
        STDERR.write( "#{e}\n\n" )
      rescue URI::InvalidURIError => e
        STDERR.write( "URI::InvalidURIError for #{@uri.path}." )
        STDERR.write( "#{e}\n\n" )
        # this may be too broad a filter
        # TODO: retry?
      rescue SystemCallError => e
        STDERR.write( "Problem connecting to server (System call error) when downloading #{@uri.path}" )
        STDERR.write( "#{e}\n\n" )
      rescue OpenSSL::SSL::SSLError => e
        STDERR.write( "OpenSSL::SSL::SSLError while downloading #{@uri.path}" )
        STDERR.write( "#{e}\n\n" )
      rescue Timeout::Error
        STDERR.write( "Timeout error connecting to #{@uri.path}" )
        STDERR.write( "#{e}\n\n" )
      end
    end
  end
end