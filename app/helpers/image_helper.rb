module ImageHelper
  def image_file(user)
    user.my_image.present? ? user.my_image : user.sns_image
  end
end
