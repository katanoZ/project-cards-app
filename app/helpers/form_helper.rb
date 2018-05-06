module FormHelper
  def error_supported_field_class(instance:, field:)
    if instance.errors[field].present?
      'form-control form-control-lg is-invalid'
    else
      'form-control form-control-lg'
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
