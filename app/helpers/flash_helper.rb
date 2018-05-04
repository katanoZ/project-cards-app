module FlashHelper
  def flash_class(key)
    if key == 'notice'
      'alert alert-primary alert-dismissible fade show'
    elsif key == 'alert'
      'alert alert-danger alert-dismissible fade show'
    end
  end
end
