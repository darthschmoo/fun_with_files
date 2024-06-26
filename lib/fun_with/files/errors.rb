module FunWith
  module Files
    # Useful... why, exactly?
    module Errors
      class Error < StandardError; end
      class SuccessionFormattingError < Error; end
      class TimestampFormatUnrecognized < Error; end
      class FileNotEmpty < Error; end
      class NotADirectory < Error; end
      class NotAFile < Error; end
    end
  end
end