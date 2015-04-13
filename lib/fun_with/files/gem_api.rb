module FunWith
  module Files
    module GemAPI
      def version
        self.root("VERSION").read
      end
    end
  end
end
    