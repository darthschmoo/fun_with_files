# The bulk of FunWith::Testing::TestCase can be found in the fun_with_testing gem.

module FunWith
  module Testing
    module TestCaseExtensions
      def install_fun_with_files_assertions
        include FunWith::Testing::Assertions::Basics        # some of the FWF assertions rely on these
        include FunWith::Testing::Assertions::FunWithFiles
      end
    end
  end
end