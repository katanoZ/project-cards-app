module MypageHelper
  def name_class(user)
    if user.errors[:name].present?
      'form-control form-control-lg text-purple mt-4 mt-md-0 is-invalid'
    else
      'form-control form-control-lg text-purple mt-4 mt-md-0'
    end
  end

  def filefield_class(user)
    if user.errors[:my_image].present?
      'btn btn-lg btn-block btn-secondary bg-light-purple border-danger text-middle-purple mt-2 mt-lg-4'
    else
      'btn btn-lg btn-block btn-secondary bg-light-purple border-middle-purple text-middle-purple mt-2 mt-lg-4'
    end
  end

  def name_error(msg)
    content_tag :div, class: 'invalid-feedback d-block' do
      I18n.t('activerecord.attributes.user.name') + msg
    end
  end

  def filefield_error(msg)
    content_tag :div, class: 'invalid-feedback d-block' do
      msg
    end
  end

  def filefield_button_text(user)
    if user.my_image.filename.present?
      user.my_image.filename
    else
      'ファイルを選択'
    end
  end
end
