module UsersHelper
  def mypage_name_class(user)
    if user.errors[:name].present?
      'form-control form-control-lg text-purple mt-4 mt-md-0 is-invalid'
    else
      'form-control form-control-lg text-purple mt-4 mt-md-0'
    end
  end

  def mypage_label_class(user)
    if user.errors[:image].present?
      'btn btn-lg btn-block btn-secondary bg-light-purple border-danger text-middle-purple mt-2 mt-lg-4'
    else
      'btn btn-lg btn-block btn-secondary bg-light-purple border-middle-purple text-middle-purple mt-2 mt-lg-4'
    end
  end
end
