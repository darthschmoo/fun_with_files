module FunWith
  module Files
    module Utils
      class Opts
        # It's tradition to pass an options hash as the last argument (creaky old tradition, named variables getting more popular)
        # Separates out that last configuration hash, if it's been given.
        def self.extract_opts_from_args( args )
          if args.last.is_a?( Hash )
            [args[0..-2], args.last ]
          else
            [args, {}]
          end
        end
        
        # Given a hash and a list of keys, return a hash that only includes the keys listed.
        def self.narrow_options( opts, keys )
          opts.keep_if{ |k,v| keys.include?( k ) }
        end
        
        def self.narrow_file_utils_options( opts, cmd )
          self.narrow_options( opts, FileUtils::OPT_TABLE[ cmd.to_s ] )
        end
      end
    end
  end
end