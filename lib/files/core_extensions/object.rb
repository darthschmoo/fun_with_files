class Object
  def fwf_blank?
    false
  end
  
  def fwf_present?
    ! self.fwf_blank?
  end
end