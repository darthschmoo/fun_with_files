module FunWith
  module Files
    module CoreExtensions
      module Object
        def fwf_blank?
          false
        end
  
        def fwf_present?
          ! self.fwf_blank?
        end
      end
    end
  end
end