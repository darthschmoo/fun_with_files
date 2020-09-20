module FunWith
  module Files
    # Useful... why, exactly?
    class Error < StandardError; end
    
    class SuccessionFormattingError < Error; end
    class TimestampFormatUnrecognized < Error; end
  end
end