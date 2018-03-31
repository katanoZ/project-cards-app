module MypageHelper
  def mypage_name_class(user)
    if user.errors[:name].present?
      'form-control form-control-lg text-purple mt-4 mt-md-0 is-invalid'
    else
      'form-control form-control-lg text-purple mt-4 mt-md-0'
    end
  end
end
